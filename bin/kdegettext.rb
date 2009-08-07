#!/usr/bin/env ruby

require 'rubygems'
require 'ruby_parser'
require 'sexp_processor'

##
# This class can only be one time instantiated (singleton class).
# The first time it gets initialized by #create the information
# about the different i18n methods are converted for later use.
# 
# For parsing the files #parse_files expects the files to parse
# (array or string) and an array containing the results of other
# already parsed files (maybe with a different parser).
#
# The result (the array targets) can be read out with #targets
class KDERubyProcessor < SexpProcessor

  # Nil if there is no instance of KDERubyProcessor yet
  @@singleton = nil

  ##
  # returns a new instance or an instance that already exists;
  # expects the same arguments as #initialize
  def self.create(*args)
    @@singleton = new(*args) unless @@singleton
    @@singleton
  end

  ##
  # sets the targets (array) to the given value
  def targets=(targets)
    @aTargetList = TargetList.import_array targets
  end

  ##
  # returns the targes (array)
  def targets
    @aTargetList.export_array if @aTargetList
  end

  ##
  # After an insstance of this class was created[#create], the
  # parser is ready to get the files (array of strings or string).
  # Already found targets can be passed over optionally.
  def parse_files(files,targets = [])
    self.targets = targets
    files.each do |file|
      self.process(RubyParser.new.parse(File.read(file), file))
    end
  end

  ##
  # overloads a function of SexpProcessor, calls are filtered,
  # checked by #check_call and if necessary post  processed
  def process_call(exp)
    # receiver is sexp: e.g. s(const, :KDE) or s(:lvar, :myinstance)
    # name is a symbol, receiver is Sexp, arguments is array
    call = { :line => exp.line, :file => exp.file, :receiver => exp[1], :name => exp[2], :arguments => [] }

    exp[3][1..-1].each do |aSexp| # iterate over arguments
      type,val = *aSexp # type is symbol, val is datatype like string or fixnum
      call[:arguments] << val
    end

    check_call call

    # pass through
    begin
      s(:call,
        *(exp.map { |inner| process_inner_expr inner })
      )
    ensure
      exp.clear
    end
  end

  private

  ##
  # analyzes the call of a method and add the call to targets,
  # if it is a i18n-call
  def check_call(call)
    if @category[:all].include? call[:name]
      msgid = ""
      if @category[:context].include? call[:name]
        msgid << call[:arguments].shift.to_s << @separator[:context]
      end
      msgid << call[:arguments].shift.to_s
      if @category[:plural].include? call[:name]
        msgid << @separator[:plural] << call[:arguments].shift.to_s
        call[:arguments].shift # removes argument after plural string
      end
      @aTargetList.add_target(msgid,call[:file].to_s + ":" + call[:line].to_s)
    end
  end

  ##
  # only important for post processing in #process_call
  def process_inner_expr(inner)
      inner.kind_of?(Array) ? process(inner) : inner
  end
  
  ##
  # called by #create it set up the variables needed to filter
  # the calls for i18n calls
  def initialize(api,separator) # :notnew:
    super()
    self.strict = false
    @category = Hash.new {|aHash,aKey| aHash[aKey] = []}
    api.each do |call|
      name = call.shift
      @category[:all] << name
      call.each do |category|
        @category[category] << name
      end
    end
    @separator = separator
  end

end

##
# This class is internally used by KDERubyProcessor to get a better
# handling for the targets, that means: to find out if i18n-calls are already used elsewere.
# 
# The two dimensional array targets is formated the following way:
#   targets = [
#     [ msgid, "file:line", "other_file:other_line", ... ]
#     ...
#   ]
class TargetList < Hash

  ##
  # call-seq:
  #   self.import_array(targets = []) -> TargetList
  #
  # creates an instance with a given set of targets in it
  def self.import_array(targets = [])
    aTargetList = self.new
    targets.each do |aTarget|
      aTargetList[aTarget.shift] = aTarget
    end
    return aTargetList
  end

  ##
  # call-seq:
  #   export_array -> targets
  #
  # exports the data to the format used by the ruby gettext framework
  def export_array
    self.map do |msgid,pos|
      [msgid] + pos
    end
  end

  ##
  # call-seq:
  #   add_target(msgid, pos) -> true or nil
  #
  # adds a target, therefore it is checked if there is already the same msgid or not;
  # 
  # returns true if target didn't existed yet, otherwise returns nil
  def add_target(msgid, pos)
    msgid.gsub!(/\n/, '\n') # escape newline: \n -> \\n
    if self.include? msgid
      self[msgid] << pos
      return nil
    else
      self[msgid] = [pos]
      return true
    end
  end

end

##
# The framework gettext for ruby is extensible by custom modules, that implement
# * a #target? method for detecting the compatiblity of this file for this parser
# * a #parse method that will be called by the framework
#
# It should be possible to add i18n-calls via
#   KDERubyParser::API << [:my_call, ... ]
# for detailed instructions see API
module KDERubyParser

  #* is a two dimensional array, each element (array) describes an i18n-call
  #* first element in array
  #  * name of the function
  #* after that other symbols defining the properties of the function
  #  * +:qt+ function from Qt or KDE framework
  #  * +:rgt+ function from ruby gettext
  #  * +:plural+ after msgid follows the argument for plural ( msgid_plural) and then a number to compute which form to use
  #  * +:context+ before msgid is argument for context (msgctxt)
  #  * +div+ last argument defines a divider string, usually div = "|"
  #* actually only +:context+ and +:plural+ are handled
  #
  #Example:
  #  API = [
  #    [:npgettext, :rgt, :context, :plural],
  #    [:ki18ncp,   :qt,  :context, :plural]
  #  ]
  API = [
    [:N_,        :rgt],
    [:_,         :rgt],
    [:gettext,   :rgt],

    [:Nn_,       :rgt, :plural], # ! only 2 arguments: singular form, plural form
    [:n_,        :rgt, :plural],

    [:p_,        :rgt, :context],
    [:pgettext,  :rgt, :context],

    [:npgettext, :rgt, :context, :plural],
    [:np_,       :rgt, :context, :plural],

    [:s_,        :rgt, :div],
    [:sgettext,  :rgt, :div],

    [:ns_,       :rgt, :div, :plural],
    [:nsgettext, :rgt, :div, :plural],

    [:i18n,      :qt],
    [:ki18n,     :qt],
    [:tr,        :qt],

    [:i18np,     :qt, :plural],
    [:ki18np,    :qt, :plural],

    [:i18nc,     :qt, :context],
    [:ki18nc,    :qt, :context],

    [:i18ncp,    :qt, :context, :plural],
    [:ki18ncp,   :qt, :context, :plural],
  ]
  
  ##
  # Hash with two values +:plural+ and +:context+, which are used as separators in the msgid string;
  # values are given by the ruby gettext project
  SEPARATOR = {:plural => "\000", :context => "\004"}

  extend self

  ##
  # call-seq:
  #   parse(files, targets = []) -> targets
  #
  # handles creation of the KDERubyProcessor and passes the targets
  def parse(files, targets = [])
    files = [files] unless files.class == Array
    aKDERubyProcessor = KDERubyProcessor.create(API,SEPARATOR)
    aKDERubyProcessor.parse_files(files,targets)
    aKDERubyProcessor.targets
  end

  ##
  # call-seq:
  #   target?(file) -> true
  #
  # needed by the ruby framework to determine if this parser is able to parse the file
  def target?(file)
    true # always true, as this parser is able to handle also normal ruby files
  end

end

begin
  require 'gettext/rgettext'
rescue LoadError
  begin
    require 'gettext/tools/rgettext'
  rescue LoadError
    raise 'Ruby-GetText-Package are not installed.'
  end
end

GetText::RGetText.add_parser(KDERubyParser)
GetText.rgettext

#!/usr/bin/env ruby
=begin
  KDEgettext.rb - parser for ruby scripts using the korundum (KDE) or qtruby (Qt) package

  Copyright (C) 2009 Robert Riemann

  You may redistribute it and/or modify it under the same
  license terms as Ruby.
=end

require 'rubygems'
require 'ruby_parser'
require 'sexp_processor'

class KDERubyProcessor < SexpProcessor

  private_class_method :new
  @@singleton = nil

  def self.create(*args)
    @@singleton = new(*args) unless @@singleton
    @@singleton
  end

  def initialize(api,separator)
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

  def targets=(targets)
    @aTargetList = TargetList.import_array targets
  end

  def targets
    @aTargetList.export_array if @aTargetList
  end

  def parse_files(files,targets = [])
    self.targets = targets
    files.each do |file|
      self.process(RubyParser.new.parse(File.read(file), file))
    end
  end

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

  def process_inner_expr(inner)
      inner.kind_of?(Array) ? process(inner) : inner
  end

end

class TargetList < Hash

  def self.import_array(targets = [])
    aTargetList = self.new
    targets.each do |aTarget|
      aTargetList[aTarget.shift] = aTarget
    end
    return aTargetList
  end

  def export_array
    self.map do |msgid,pos|
      [msgid] + pos
    end
  end

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

module KDERubyParser

  # Syntax:
  #
  # first element in array: name of the function,
  # after that other symbols defining the properties of the function :
  # * qt : function from Qt or KDE framework
  # * rgt (ruby gettext) : function from ruby gettext
  # * plural : after msgid follows the argument for plural ( msgid_plural) and then a number to compute which form to use
  # * context : before msgid is argument for context (msgctxt)
  # * div : last argument defines a divider string, usually div = "|"
  # actually only context and plural are handled
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

  SEPARATOR = {:plural => "\000", :context => "\004"}

  extend self

  def parse(files, targets = []) # :nodoc: # files is string (1 file) or array (more files)
    files = [files] unless files.class == Array
    aKDERubyProcessor = KDERubyProcessor.create(API,SEPARATOR)
    aKDERubyProcessor.parse_files(files,targets)
    aKDERubyProcessor.targets
  end

  def target?(file) # :nodoc:
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
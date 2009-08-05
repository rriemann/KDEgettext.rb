require 'rake'
require 'git'

begin
  require 'jeweler'
  Jeweler::Tasks.new do |s|
    s.name = %q{kdegettext}
    s.date = %q{2009-08-05}
    s.authors = ["Robert Riemann"]
    s.email = %q{robert.riemann@physik.hu-berlin.de}
    s.summary = %q{KDEgettext.rb is a tool to localize KDE programs implemented in ruby.}
    s.homepage = %q{http://github.com/saLOUt/KDEgettext.rb/}
    s.description = %q{KDEgettext.rb is a parser that extends ruby gettext to work with the Qt/KDE framework provided by korundum. It allows creating catalog files (po-file) with the GNU GetText format.}
    s.add_dependency('gettext', '>= 2.0.4')
    s.add_dependency('locale', '>= 2.0.4')
    s.add_dependency('ruby_parser', '>= 2.0.3')
    s.add_dependency('sexp_processor', '>= 3.0.2')
    s.has_rdoc = false
  end

rescue LoadError
  puts "Jeweler, or one of its dependencies, is not available. Install it with: sudo gem install jeweler"
end
# kate: syntax ruby

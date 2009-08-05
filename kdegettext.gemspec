# Generated by jeweler
# DO NOT EDIT THIS FILE
# Instead, edit Jeweler::Tasks in Rakefile, and run `rake gemspec`
# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{kdegettext}
  s.version = "0.9.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Robert Riemann"]
  s.date = %q{2009-08-05}
  s.description = %q{KDEgettext.rb is a parser that extends ruby gettext to work with the Qt/KDE framework provided by korundum. It allows creating catalog files (po-file) with the GNU GetText format.}
  s.email = %q{robert.riemann@physik.hu-berlin.de}
  s.executables = ["kdegettext.rb", "kdegettext.rb~"]
  s.extra_rdoc_files = [
    "LICENSE",
     "README"
  ]
  s.files = [
    "Changelog",
     "LICENSE",
     "README",
     "Rakefile",
     "VERSION",
     "bin/kdegettext.rb"
  ]
  s.homepage = %q{http://github.com/saLOUt/KDEgettext.rb/}
  s.rdoc_options = ["--charset=UTF-8"]
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.1}
  s.summary = %q{KDEgettext.rb is a tool to localize KDE programs implemented in ruby.}

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 2

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<gettext>, [">= 2.0.4"])
      s.add_runtime_dependency(%q<locale>, [">= 2.0.4"])
      s.add_runtime_dependency(%q<ruby_parser>, [">= 2.0.3"])
      s.add_runtime_dependency(%q<sexp_processor>, [">= 3.0.2"])
    else
      s.add_dependency(%q<gettext>, [">= 2.0.4"])
      s.add_dependency(%q<locale>, [">= 2.0.4"])
      s.add_dependency(%q<ruby_parser>, [">= 2.0.3"])
      s.add_dependency(%q<sexp_processor>, [">= 3.0.2"])
    end
  else
    s.add_dependency(%q<gettext>, [">= 2.0.4"])
    s.add_dependency(%q<locale>, [">= 2.0.4"])
    s.add_dependency(%q<ruby_parser>, [">= 2.0.3"])
    s.add_dependency(%q<sexp_processor>, [">= 3.0.2"])
  end
end

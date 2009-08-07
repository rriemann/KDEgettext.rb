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
    s.has_rdoc = true
    s.rubyforge_project = "korundum"
  end
  
  Jeweler::RubyforgeTasks.new do |rubyforge|
    rubyforge.doc_task = "rdoc"
  end

rescue LoadError
  puts "Jeweler, or one of its dependencies, is not available. Install it with: sudo gem install jeweler"
end

require 'rake/testtask'
Rake::TestTask.new(:test) do |test|
  test.libs << 'lib' << 'test'
  test.pattern = 'test/**/*_test.rb'
  test.verbose = true
end

begin
  require 'rcov/rcovtask'
  Rcov::RcovTask.new do |test|
    test.libs << 'test'
    test.pattern = 'test/**/*_test.rb'
    test.verbose = true
  end
rescue LoadError
  task :rcov do
    abort "RCov is not available. In order to run rcov, you must: sudo gem install spicycode-rcov"
  end
end

task :test => :check_dependencies

task :default => :test

require 'rake/rdoctask'
Rake::RDocTask.new do |rdoc|
  if File.exist?('VERSION')
    version = File.read('VERSION')
  else
    abort "No file VERSION found."
  end
  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = "KDEgettext.rb #{version}"
  rdoc.rdoc_files.include('README.markdown')
  rdoc.rdoc_files.include('bin/*')
end

# kate: syntax ruby

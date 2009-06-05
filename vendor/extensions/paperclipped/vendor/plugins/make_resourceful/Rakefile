require 'rake'
require 'rake/testtask'
require 'rake/rdoctask'
require 'spec/rake/spectask'

desc 'Default: run unit tests.'
task :default => :test

spec_files = Rake::FileList["spec/**/*_spec.rb"]

desc "Run specs"
Spec::Rake::SpecTask.new do |t|
  t.spec_files = spec_files
  t.spec_opts = ["-c"]
end

desc "Generate code coverage"
Spec::Rake::SpecTask.new(:coverage) do |t|
  t.spec_files = spec_files
  t.rcov = true
  t.rcov_opts = ['--exclude', 'spec,/var/lib/gems']
end

desc 'Test the make_resourceful plugin.'
task :test do
  Dir.chdir(File.dirname(__FILE__) + '/test')
  tests = IO.popen('rake test')

  while byte = tests.read(1)
    print byte
  end
end

desc 'Generate documentation for the make_resourceful plugin.'
Rake::RDocTask.new(:rdoc) do |rdoc|
  rdoc.rdoc_dir = 'rdoc'
  rdoc.title    = 'make_resourceful'
  rdoc.options << '--line-numbers' << '--inline-source'
  rdoc.main = 'README'
  rdoc.rdoc_files.include(FileList.new('*').exclude(/[^A-Z0-9]/))
  rdoc.rdoc_files.include('lib/**/*.rb')
end

$:.unshift(File.join(File.dirname(__FILE__), 'lib'))

require File.join(File.dirname(__FILE__), 'plugit/descriptor')
require 'rubygems'
require 'spec/rake/spectask'

task :default => :spec

desc "Run all specs"
Spec::Rake::SpecTask.new do |t|
  t.spec_files = FileList['spec/**/*_spec.rb']
  t.spec_opts = ['--options', 'spec/spec.opts']
end

begin
  require 'jeweler'
  Jeweler::Tasks.new do |s|
    s.name = 'dataset'
    s.summary = 'A simple API for creating and finding sets of data in your database, built on ActiveRecord.'
    s.email = 'adam@thewilliams.ws'
    s.files = FileList["[A-Z]*", "{lib,tasks}/**/*", "plugit/descriptor.rb"].exclude("tmp")
    s.require_paths = ["lib", "tasks"]
    s.add_dependency('activesupport', '>= 2.3.0')
    s.add_dependency('activerecord', '>= 2.3.0')
    s.homepage = "http://github.com/aiwilliams/dataset"
    s.description = s.summary
    s.authors = ['Adam Williams']
  end
rescue LoadError
  puts "Jeweler not available. Install it with: sudo gem install technicalpickles-jeweler -s http://gems.github.com"
end
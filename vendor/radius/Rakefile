require 'rubygems'
require 'rake/testtask'
require 'rake/rdoctask'
require 'rake/gempackagetask'

PKG_NAME = 'radius'
PKG_VERSION = '0.5.1'
PKG_FILE_NAME = "#{PKG_NAME}-#{PKG_VERSION}"
RUBY_FORGE_PROJECT = PKG_NAME
RUBY_FORGE_USER = 'jlong'

RELEASE_NAME  = PKG_VERSION
RUBY_FORGE_GROUPID = '1262'
RUBY_FORGE_PACKAGEID = '1538'

RDOC_TITLE = "Radius -- Powerful Tag-Based Templates"
RDOC_EXTRAS = ["README", "QUICKSTART", "ROADMAP", "CHANGELOG"]

task :default => :test

Rake::TestTask.new do |t| 
  t.pattern = 'test/**/*_test.rb'
end

Rake::RDocTask.new do |rd|
  rd.title = 'Radius -- Powerful Tag-Based Templates'
  rd.main = "README"
  rd.rdoc_files.include("lib/**/*.rb")
  rd.rdoc_files.include(RDOC_EXTRAS)
  rd.rdoc_dir = 'doc'
end

spec = Gem::Specification.new do |s|
  s.name = PKG_NAME
  s.version = PKG_VERSION
  s.summary = 'Powerful tag-based template system.'
  s.description = "Radius is a small, but powerful tag-based template language for Ruby\nsimilar to the ones used in MovableType and TextPattern. It has tags\nsimilar to HTML or XML, but can be used to generate any form of plain\ntext (not just HTML)."
  s.homepage = 'http://radius.rubyforge.org'
  s.rubyforge_project = RUBY_FORGE_PROJECT
  s.platform = Gem::Platform::RUBY
  s.requirements << 'none'
  s.require_path = 'lib'
  s.autorequire = 'radius'
  s.has_rdoc = true
  s.rdoc_options << '--title' << RDOC_TITLE << '--line-numbers' << '--main' << 'README'
  s.extra_rdoc_files = RDOC_EXTRAS
  files = FileList['**/*']
  files.exclude 'doc'
  files.exclude '**/._*'
  s.files = files.to_a
end

Rake::GemPackageTask.new(spec) do |pkg|
  pkg.need_zip = true
  pkg.need_tar = true
end

desc "Uninstall Gem"
task :uninstall_gem do
  sh "gem uninstall radius" rescue nil
end

desc "Build and install Gem from source"
task :install_gem => [:package, :uninstall_gem] do
  dir = File.join(File.dirname(__FILE__), 'pkg')
  chdir(dir) do
    latest = Dir['radius-*.gem'].last
    sh "gem install #{latest}"
  end
end

# --- Ruby forge release manager by florian gross -------------------------------------------------
#
# task found in Tobias Luetke's library 'liquid'
#

desc "Publish the release files to RubyForge."
task :release => [:gem, :package] do
  files = ["gem", "tgz", "zip"].map { |ext| "pkg/#{PKG_FILE_NAME}.#{ext}" }

  system("rubyforge login --username #{RUBY_FORGE_USER}")
  
  files.each do |file|
    system("rubyforge add_release #{RUBY_FORGE_GROUPID} #{RUBY_FORGE_PACKAGEID} \"#{RELEASE_NAME}\" #{file}")
  end
end

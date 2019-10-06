# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "radiant-<%= file_name %>-extension"

Gem::Specification.new do |s|
  s.name        = "radiant-<%= file_name %>-extension"
  s.version     = Radiant<%= class_name %>::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = Radiant<%= class_name %>::AUTHORS
  s.email       = Radiant<%= class_name %>::EMAIL
  s.homepage    = Radiant<%= class_name %>::URL
  s.summary     = Radiant<%= class_name %>::SUMMARY
  s.description = Radiant<%= class_name %>::DESCRIPTION

  # Define gem dependencies here.
  # Don't include a dependency on radiant itself: it causes problems when radiant is in vendor/radiant.
  # s.add_dependency "something", "~> 1.0.0"
  # s.add_dependency "radiant-some-extension", "~> 1.0.0"

  ignores = if File.exist?('.gitignore')
    File.read('.gitignore').split("\n").inject([]) {|a,p| a + Dir[p] }
  else
    []
  end
  s.files         = Dir['**/*'] - ignores
  s.test_files    = Dir['test/**/*','spec/**/*','features/**/*'] - ignores
  # s.executables   = Dir['bin/*'] - ignores
  s.require_paths = ["lib"]
end

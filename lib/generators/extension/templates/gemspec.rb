# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "radiant-<%= file_name %>-extension/version"

Gem::Specification.new do |s|
  s.name        = "radiant-<%= file_name %>-extension"
  s.version     = Radiant<%= class_name %>::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["<%= author_name %>"]
  s.email       = ["<%= author_email %>"]
  s.homepage    = "<%= homepage %>"
  s.summary     = %q{<%= extension_name %> for Radiant CMS}
  s.description = %q{Makes Radiant better by adding <%= file_name %>!}
  
  ignores = if File.exist?('.gitignore')
    File.read('.gitignore').split("\n").inject([]) {|a,p| a + Dir[p] }
  else
    []
  end
  s.files         = Dir['**/*'] - ignores
  s.test_files    = Dir['test/**/*','spec/**/*','features/*'] - ignores
  # s.executables   = Dir['bin/*'] - ignores
  s.require_paths = ["lib"]
  
  s.post_install_message = %{
  Add this to your radiant project with:
    config.gem 'radiant-<%= file_name %>-extension', :version => '~>#{Radiant<%= class_name %>::VERSION}'
  }
end
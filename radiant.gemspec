# -*- encoding: utf-8 -*-
require File.expand_path(__FILE__ + '/../lib/radiant.rb')
Gem::Specification.new do |s|
  s.name = "radiant"
  s.version = Radiant::Version.to_s
  s.platform = Gem::Platform::RUBY

  s.required_ruby_version = ">= 3.2"
  s.authors = ["Radiant CMS dev team"]
  s.description = "Radiant is a simple and powerful publishing system designed for small teams. " \
                  "It is built with Rails and is similar to Textpattern or MovableType, but is " \
                  "a general purpose content management system--not merely a blogging engine."
  s.email = "radiant@radiantcms.org"
  s.executables = ["radiant"]
  s.extra_rdoc_files = ["README.md", "CONTRIBUTORS.md", "CHANGELOG.md", "INSTALL.md", "LICENSE.md"]
  ignores = File.read('.gitignore').split("\n").inject([]) {|a,p| a + Dir[p] }
  s.files = Dir['**/*','.gitignore', 'public/.htaccess', 'log/.keep', 'vendor/extensions/.keep'] - ignores
  s.homepage = "http://radiantcms.org"
  s.require_paths = ["lib"]
  s.summary = "A no-fluff content management system designed for small teams."
  s.license = "MIT"

  s.add_dependency "rails",         "~> 8.0"
  s.add_dependency "propshaft"
  s.add_dependency "radius",        "~> 0.7"
  s.add_dependency "acts_as_tree"
  s.add_dependency "RedCloth"
  s.add_dependency "will_paginate"
end

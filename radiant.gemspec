# -*- encoding: utf-8 -*-
require File.expand_path(__FILE__ + '/../lib/radiant.rb')
Gem::Specification.new do |s|
  s.name = %q{radiant}
  s.version = Radiant::Version.to_s
  s.platform = Gem::Platform::RUBY

  s.required_rubygems_version = Gem::Requirement.new("> 1.3.1") if s.respond_to? :required_rubygems_version=
  s.authors = ["Radiant CMS dev team"]
  s.default_executable = %q{radiant}
  s.description = %q{Radiant is a simple and powerful publishing system designed for small teams.
It is built with Rails and is similar to Textpattern or MovableType, but is
a general purpose content managment system--not merely a blogging engine.}
  s.email = %q{radiant@radiantcms.org}
  s.executables = ["radiant"]
  s.extra_rdoc_files = ["README.md", "CONTRIBUTORS.md", "CHANGELOG.md", "INSTALL.md", "LICENSE.md"]
  ignores = File.read('.gitignore').split("\n").inject([]) {|a,p| a + Dir[p] }
  s.files = Dir['**/*','.gitignore', 'public/.htaccess', 'log/.keep', 'vendor/extensions/.keep'] - ignores
  s.homepage = %q{http://radiantcms.org}
  s.rdoc_options = ["--title", "Radiant -- Publishing for Small Teams", "--line-numbers", "--main", "README", "--exclude", "app", "--exclude", "bin", "--exclude", "config", "--exclude", "db", "--exclude", "features", "--exclude", "lib", "--exclude", "log", "--exclude", "pkg", "--exclude", "public", "--exclude", "script", "--exclude", "spec", "--exclude", "test", "--exclude", "tmp", "--exclude", "vendor"]
  s.summary = %q{A no-fluff content management system designed for small teams.}

  s.add_dependency "rails",         "~> 3.2.0"
  s.add_dependency "bundler",       ">= 1.0.0"
  s.add_dependency "compass"
  s.add_dependency "delocalize"
  s.add_dependency "haml"
  s.add_dependency "rack"
  s.add_dependency "rack-cache"
  s.add_dependency "rake"
  s.add_dependency "radius"
  s.add_dependency "will_paginate"

  s.add_development_dependency "cucumber-rails"
  s.add_development_dependency "database_cleaner"
  s.add_development_dependency "capybara"
  s.add_development_dependency "rspec"
  s.add_development_dependency "rspec-rails"
  s.add_development_dependency "ZenTest"
end

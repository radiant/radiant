# -*- encoding: utf-8 -*-
require File.expand_path(__FILE__ + '/../lib/radiant/version.rb')
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
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{radiant}
  s.rubygems_version = %q{1.3.7}
  s.summary = %q{A no-fluff content management system designed for small teams.}
  s.license = %q{MIT}

  s.add_dependency "rails",           ">= 4.2"
  s.add_dependency "rails-observers", "~> 0.1.2"
  s.add_dependency "activeresource",  ">= 3.2"
  s.add_dependency "protected_attributes", "~> 1.1.3"
  s.add_dependency "acts_as_tree",    "~> 2.4.0"
  s.add_dependency "compass",         "~> 1.0.3"
  s.add_dependency "compass-rails",   "~> 2.0.4"
  s.add_dependency "haml",            "~> 4.0.6"
  s.add_dependency "highline",        "~> 1.6"
  s.add_dependency "rack-cache",      "~> 1.2"
  s.add_dependency "rake",            "~> 10.4"
  s.add_dependency "radius",          "~> 0.7"
  s.add_dependency "RedCloth",        "~> 4.2"
  s.add_dependency "stringex",        "~> 1.3"
  s.add_dependency "tzinfo",          "~> 1.2.2"
  s.add_dependency "will_paginate",   "~> 3.1"

  s.add_development_dependency "pry-byebug"

  s.add_development_dependency "cucumber-rails",            "~> 1.4"
  s.add_development_dependency "database_cleaner",          "~> 1.1"
  s.add_development_dependency "capybara",                  "~> 2.1"
  s.add_development_dependency "factory_girl",              "~> 4.7"
  s.add_development_dependency "rspec",                     "~> 3.4.0"
  s.add_development_dependency "rspec-rails",               "~> 3.4.2"
  s.add_development_dependency "rspec-its",                 "~> 1.0"
  s.add_development_dependency "rspec-collection_matchers", "~> 1.1"
  s.add_development_dependency "rspec-activemodel-mocks",   "~> 1.0"
  s.add_development_dependency "combustion",                "~> 0.5.4"
  s.add_development_dependency "sqlite3",                   "~> 1.3"
end

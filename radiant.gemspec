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
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{radiant}
  s.rubygems_version = %q{1.3.7}
  s.summary = %q{A no-fluff content management system designed for small teams.}

  s.add_dependency "rails",           "~> 2.3.12"
  s.add_dependency "rdoc",            "~> 3.9.2"
  s.add_dependency "acts_as_tree",    "~> 0.1.1"
  s.add_dependency "bundler",         "~> 1.0.0"
  s.add_dependency "compass",         "~> 0.11.1"
  s.add_dependency "delocalize",      "~> 0.2.3"
  s.add_dependency "haml",            "~> 3.1.1"
  s.add_dependency "highline",        "~> 1.6.2"
  s.add_dependency "rack",            "~> 1.1.1"
  s.add_dependency "rack-cache",      "~> 1.0.2"
  s.add_dependency "rake",            "> 0.8.6"
  s.add_dependency "radius",          "~> 0.7.1"
  s.add_dependency "term-ansicolor",  "~> 1.0.6"
  s.add_dependency "will_paginate",   "~> 2.3.11"

  s.add_dependency "radiant-archive-extension",             "~> 1.0.0"
  s.add_dependency "radiant-clipped-extension",             "~> 1.0.6"
  s.add_dependency "radiant-debug-extension",               "~> 1.0.0"
  s.add_dependency "radiant-exporter-extension",            "~> 1.0.0"
  s.add_dependency "radiant-markdown_filter-extension",     "~> 1.0.0"
  s.add_dependency "radiant-sheets-extension",              "~> 1.0.0.pre"
  s.add_dependency "radiant-site_templates-extension",      "~> 1.0.0"
  s.add_dependency "radiant-smarty_pants_filter-extension", "~> 1.0.0"
  s.add_dependency "radiant-textile_filter-extension",      "~> 1.0.0"
  
  s.add_development_dependency "cucumber-rails",    "~> 0.3.2"
  s.add_development_dependency "database_cleaner",  "~> 0.6.5"
  s.add_development_dependency "hoe",               "1.5.1"
  s.add_development_dependency "webrat",            "~> 0.7.3"
  s.add_development_dependency "rspec",             "~> 1.3.1"
  s.add_development_dependency "rspec-rails",       "~> 1.3.3"
  s.add_development_dependency "sqlite3",           "~> 1.3.4"
  s.add_development_dependency "test-unit",         "1.2.3"
  s.add_development_dependency "ZenTest",           "4.6.0"
  
end

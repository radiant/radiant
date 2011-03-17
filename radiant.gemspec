# -*- encoding: utf-8 -*-
require File.expand_path(__FILE__ + '/../lib/radiant.rb')
Gem::Specification.new do |s|
  s.name = %q{radiant}
  s.version = Radiant::Version.to_s

  s.required_rubygems_version = Gem::Requirement.new("> 1.3.1") if s.respond_to? :required_rubygems_version=
  s.authors = ["Radiant CMS dev team"]
  s.date = %q{2010-06-27}
  s.default_executable = %q{radiant}
  s.description = %q{Radiant is a simple and powerful publishing system designed for small teams.
It is built with Rails and is similar to Textpattern or MovableType, but is
a general purpose content managment system--not merely a blogging engine.}
  s.email = %q{radiant@radiantcms.org}
  s.executables = ["radiant"]
  s.extra_rdoc_files = ["README", "CONTRIBUTORS", "CHANGELOG", "INSTALL", "LICENSE"]
  ignores = File.read('.gitignore').split("\n").inject([]) {|a,p| a + Dir[p] }
  s.files = Dir['**/*','.gitignore', 'public/.htaccess'] - ignores
  s.homepage = %q{http://radiantcms.org}
  s.rdoc_options = ["--title", "Radiant -- Publishing for Small Teams", "--line-numbers", "--main", "README", "--exclude", "app", "--exclude", "bin", "--exclude", "config", "--exclude", "db", "--exclude", "features", "--exclude", "lib", "--exclude", "log", "--exclude", "pkg", "--exclude", "public", "--exclude", "script", "--exclude", "spec", "--exclude", "test", "--exclude", "tmp", "--exclude", "vendor"]
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{radiant}
  s.rubygems_version = %q{1.3.7}
  s.summary = %q{A no-fluff content management system designed for small teams.}

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<rake>, [">= 0.8.3"])
      s.add_runtime_dependency(%q<rack>, ["~> 1.1.0"])
      s.add_runtime_dependency(%q<will_paginate>, ["~> 2.3.11"])
      s.add_runtime_dependency(%q<RedCloth>, [">= 4.0.0"])
    else
      s.add_dependency(%q<rake>, [">= 0.8.3"])
      s.add_dependency(%q<rack>, ["~> 1.1.0"])
      s.add_dependency(%q<will_paginate>, ["~> 2.3.11"])
      s.add_dependency(%q<RedCloth>, [">= 4.0.0"])
    end
  else
    s.add_dependency(%q<rake>, [">= 0.8.3"])
    s.add_dependency(%q<rack>, ["~> 1.1.0"])
    s.add_dependency(%q<will_paginate>, ["~> 2.3.11"])
    s.add_dependency(%q<RedCloth>, [">= 4.0.0"])
  end
  
  s.add_development_dependency 'cucumber', '> 0.3.9'
  s.add_development_dependency 'compass', '~> 0.10.5'
  s.add_development_dependency 'cucumber-rails', '~> 0.3.2'
  s.add_development_dependency 'database_cleaner', '~> 0.6.5'
  s.add_development_dependency 'webrat', '~> 0.7.3'
  s.add_development_dependency 'rspec', '~> 1.3.1'
  s.add_development_dependency 'rspec-rails', '~> 1.3.3'
end

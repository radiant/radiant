# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{dataset}
  s.version = "1.3.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Adam Williams"]
  s.date = %q{2009-06-12}
  s.description = %q{A simple API for creating and finding sets of data in your database, built on ActiveRecord.}
  s.email = %q{adam@thewilliams.ws}
  s.files = ["CHANGELOG", "LICENSE", "Rakefile", "README", "TODO", "VERSION.yml", "lib/dataset", "lib/dataset/base.rb", "lib/dataset/collection.rb", "lib/dataset/database", "lib/dataset/database/base.rb", "lib/dataset/database/mysql.rb", "lib/dataset/database/postgresql.rb", "lib/dataset/database/sqlite3.rb", "lib/dataset/extensions", "lib/dataset/extensions/cucumber.rb", "lib/dataset/extensions/rspec.rb", "lib/dataset/extensions/test_unit.rb", "lib/dataset/instance_methods.rb", "lib/dataset/load.rb", "lib/dataset/record", "lib/dataset/record/fixture.rb", "lib/dataset/record/meta.rb", "lib/dataset/record/model.rb", "lib/dataset/resolver.rb", "lib/dataset/session.rb", "lib/dataset/session_binding.rb", "lib/dataset/version.rb", "lib/dataset.rb", "tasks/dataset.rake", "plugit/descriptor.rb"]
  s.homepage = %q{http://github.com/aiwilliams/dataset}
  s.require_paths = ["lib", "tasks"]
  s.rubygems_version = %q{1.3.1}
  s.summary = %q{A simple API for creating and finding sets of data in your database, built on ActiveRecord.}

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 2

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<activesupport>, [">= 2.3.0"])
      s.add_runtime_dependency(%q<activerecord>, [">= 2.3.0"])
    else
      s.add_dependency(%q<activesupport>, [">= 2.3.0"])
      s.add_dependency(%q<activerecord>, [">= 2.3.0"])
    end
  else
    s.add_dependency(%q<activesupport>, [">= 2.3.0"])
    s.add_dependency(%q<activerecord>, [">= 2.3.0"])
  end
end

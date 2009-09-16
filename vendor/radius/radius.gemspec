# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{radius}
  s.version = "0.6.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["John W. Long (me@johnwlong.com)", "David Chelimsky (dchelimsky@gmail.com)", "Bryce Kerley (bkerley@brycekerley.net)"]
  s.date = %q{2009-04-07}
  s.description = %q{Radius is a powerful tag-based template language for Ruby inspired by the template languages used in MovableType[http://www.movabletype.org] and TextPattern[http://www.textpattern.com]. It uses tags similar to XML, but can be used to generate any form of plain text (HTML, e-mail, etc...).}
  s.email = ["me@johnwlong.com"]
  s.extra_rdoc_files = ["Manifest.txt", "README.rdoc"]
  s.files = ["CHANGELOG", "Manifest.txt", "QUICKSTART", "README.rdoc", "Rakefile", "lib/radius.rb", "lib/radius/context.rb", "lib/radius/dostruct.rb", "lib/radius/error.rb", "lib/radius/parser.rb", "lib/radius/parser/scan.rb", "lib/radius/parser/scan.rl", "lib/radius/parsetag.rb", "lib/radius/tagbinding.rb", "lib/radius/tagdefs.rb", "lib/radius/util.rb", "tasks/scan.rake", "test/context_test.rb", "test/parser_test.rb", "test/test_helper.rb"]
  s.has_rdoc = true
  s.homepage = %q{http://rubyforge.org/projects/radius/}
  s.rdoc_options = ["--main", "README.rdoc"]
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{radius}
  s.rubygems_version = %q{1.3.1}
  s.summary = %q{Radius is a powerful tag-based template language for Ruby inspired by the template languages used in MovableType[http://www.movabletype.org] and TextPattern[http://www.textpattern.com]}
  s.test_files = ["test/context_test.rb", "test/parser_test.rb"]

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 2

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
      s.add_development_dependency(%q<newgem>, [">= 1.2.3"])
      s.add_development_dependency(%q<hoe>, [">= 1.8.0"])
    else
      s.add_dependency(%q<newgem>, [">= 1.2.3"])
      s.add_dependency(%q<hoe>, [">= 1.8.0"])
    end
  else
    s.add_dependency(%q<newgem>, [">= 1.2.3"])
    s.add_dependency(%q<hoe>, [">= 1.8.0"])
  end
end

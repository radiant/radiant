begin
  require 'jeweler'
  Jeweler::Tasks.new do |gem|
    gem.name = "radius"
    gem.summary = "A tag-based templating language for Ruby."
    gem.description = "Radius is a powerful tag-based template language for Ruby inspired by the template languages used in MovableType and TextPattern. It uses tags similar to XML, but can be used to generate any form of plain text (HTML, e-mail, etc...)."
    gem.email = "me@johnwlong.com"
    gem.homepage = "http://github.com/jlong/radius"
    gem.authors = [
      "John W. Long (me@johnwlong.com)",
      "David Chelimsky (dchelimsky@gmail.com)",
      "Bryce Kerley (bkerley@brycekerley.net)"
    ]
    gem.files = FileList["[A-Z]*", "{bin,lib,tasks,test}/**/*"].exclude("tmp")
    gem.extra_rdoc_files = ['README.rdoc', 'QUICKSTART.rdoc', 'LICENSE', 'CHANGELOG']
    # gem is a Gem::Specification... see http://www.rubygems.org/read/chapter/20 for additional settings
  end
  Jeweler::GemcutterTasks.new
rescue LoadError
  puts "Jeweler (or a dependency) not available. Install it with: gem install jeweler"
end
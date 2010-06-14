# Rakefile for rubypants  -*-ruby-*-
require 'rake/rdoctask'
require 'rake/gempackagetask'


desc "Run all the tests"
task :default => [:test]

desc "Do predistribution stuff"
task :predist => [:doc]


desc "Run all the tests"
task :test do
  ruby 'test_rubypants.rb'
end

desc "Make an archive as .tar.gz"
task :dist => :test do
  system "darcs dist -d rubypants#{get_darcs_tree_version}"
end


desc "Generate RDoc documentation"
Rake::RDocTask.new(:doc) do |rdoc|
  rdoc.options << '--line-numbers --inline-source --all'
  rdoc.rdoc_files.include 'README'
  rdoc.rdoc_files.include 'rubypants.rb'
end


spec = Gem::Specification.new do |s|
  s.name = 'rubypants'
  s.version = '0.2.0'
  s.summary = "RubyPants is a Ruby port of the smart-quotes library SmartyPants."
  s.description = <<-EOF
RubyPants is a Ruby port of the smart-quotes library SmartyPants.

The original "SmartyPants" is a free web publishing plug-in for
Movable Type, Blosxom, and BBEdit that easily translates plain ASCII
punctuation characters into "smart" typographic punctuation HTML
entities.
  EOF
  s.files = FileList['**/*rb', 'README', 'Rakefile'].to_a
  s.test_file = "test_rubypants.rb"
  s.extra_rdoc_files = ["README"]
  s.rdoc_options = ["--main", "README"]
  s.rdoc_options.concat ['--line-numbers', '--inline-source', '--all']
  s.rdoc_options.concat ['--exclude',  'test_rubypants.rb']
  s.require_path = '.'
  s.author = "Christian Neukirchen"
  s.email = "chneukirchen@gmail.com"
  s.homepage = "http://www.kronavita.de/chris/blog/projects/rubypants.html"
end

Rake::GemPackageTask.new(spec) do |pkg|
end


# Helper to retrieve the "revision number" of the darcs tree.
def get_darcs_tree_version
  return ""  unless File.directory? "_darcs"

  changes = `darcs changes`
  count = 0
  tag = "0.0"
  
  changes.each("\n\n") { |change|
    head, title, desc = change.split("\n", 3)
    
    if title =~ /^  \*/
      # Normal change.
      count += 1
    elsif title =~ /tagged (.*)/
      # Tag.  We look for these.
      tag = $1
      break
    else
      warn "Unparsable change: #{change}"
    end
  }

  "-" + tag + "." + count.to_s
end

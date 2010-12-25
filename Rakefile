PKG_NAME    = 'radiant'
RDOC_TITLE  = "Radiant -- Publishing for Small Teams"
RDOC_EXTRAS = ["README", "CONTRIBUTORS", "CHANGELOG", "INSTALL", "LICENSE"]

require 'rake'
require 'rake/testtask'
require 'rake/rdoctask'

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gemspec|
    gemspec.name = PKG_NAME
    gemspec.summary = "A no-fluff content management system designed for small teams."
    gemspec.email = "radiant@radiantcms.org"
    gemspec.homepage = "http://github.com/jbasdf/disguise"
    gemspec.description = "Radiant is a simple and powerful publishing system designed for small teams.\nIt is built with Rails and is similar to Textpattern or MovableType, but is\na general purpose content managment system--not merely a blogging engine."
    gemspec.authors = ["Radiant CMS dev team"]
    gemspec.bindir = 'bin'
    gemspec.executables = (Dir['bin/*'] + Dir['scripts/*']).map { |file| File.basename(file) } 
    gemspec.has_rdoc = true
    gemspec.rdoc_options << '--title' << RDOC_TITLE << '--line-numbers' << '--main' << 'README'
    rdoc_excludes = Dir["**"].reject { |f| !File.directory? f }
    rdoc_excludes.each do |e|
      gemspec.rdoc_options << '--exclude' << e
    end
    gemspec.extra_rdoc_files = RDOC_EXTRAS
    files = FileList['**/*']
    files.exclude '**/._*'
    files.exclude '**/*.rej'
    files.exclude '.git*'
    files.exclude /^cache/
    files.exclude 'config/database.yml'
    files.exclude 'config/locomotive.yml'
    files.exclude 'config/lighttpd.conf'
    files.exclude 'config/mongrel_mimes.yml'
    files.exclude 'db/*.db'
    files.exclude /^doc/
    files.exclude 'log/*.log'
    files.exclude 'log/*.pid'
    files.include 'log/.keep'
    files.exclude /^pkg/
    files.include 'public/.htaccess'
    files.exclude /\btmp\b/
    files.exclude 'radiant.gemspec'
    files.exclude 'test/railsapp'
    # Read .gitignore from plugins and exclude those files
    Dir['vendor/plugins/*/.gitignore'].each do |gi|
      dirname = File.dirname(gi)
      File.readlines(gi).each do |i|
        files.exclude "#{dirname}/**/#{i}"
      end
    end
    gemspec.files = files.to_a
    
    gemspec.add_dependency 'rake',          '~> 0.8.7'
    gemspec.add_dependency 'rack',          '~> 1.2.1'
    gemspec.add_dependency 'haml',          '~> 3.0.23'
    gemspec.add_dependency 'compass',       '~> 0.10.4'
    gemspec.add_dependency 'rdiscount',     '~> 1.5.8'
    gemspec.add_dependency 'rubypants',     '~> 0.0.2'
    gemspec.add_dependency 'highline',      '~> 1.5.2'
    gemspec.add_dependency 'will_paginate', '~> 2.3.15'
    gemspec.add_dependency 'acts_as_tree',  '~> 0.1.1'
    gemspec.add_dependency 'RedCloth',      '~> 4.2.2'
    gemspec.add_dependency 'rack-cache',    '~> 0.5.2'
    gemspec.add_dependency 'radius',        '~> 0.7.0.prerelease'
  end
  Jeweler::GemcutterTasks.new
rescue LoadError
  puts "Jeweler (or a dependency) not available. Install it with: sudo gem install jeweler"
end
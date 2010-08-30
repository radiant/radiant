require 'rubygems'
require 'rake/testtask'
require 'rake/rdoctask'
require 'rake/gempackagetask'
require 'radiant'

PKG_NAME = 'radiant'
PKG_VERSION = Radiant::Version.to_s
PKG_FILE_NAME = "#{PKG_NAME}-#{PKG_VERSION}"
RUBY_FORGE_PROJECT = PKG_NAME
RUBY_FORGE_USER = ENV['RUBY_FORGE_USER'] || 'jlong'

RELEASE_NAME  = ENV['RELEASE_NAME'] || PKG_VERSION
RELEASE_NOTES = ENV['RELEASE_NOTES'] ? " -n #{ENV['RELEASE_NOTES']}" : ''
RELEASE_CHANGES = ENV['RELEASE_CHANGES'] ? " -a #{ENV['RELEASE_CHANGES']}" : ''
RUBY_FORGE_GROUPID = '1337'
RUBY_FORGE_PACKAGEID = '1638'

RDOC_TITLE = "Radiant -- Publishing for Small Teams"
RDOC_EXTRAS = ["README", "CONTRIBUTORS", "CHANGELOG", "INSTALL", "LICENSE"]

namespace 'radiant' do
  spec = Gem::Specification.new do |s|
    s.name = PKG_NAME
    s.version = PKG_VERSION
    s.author = "Radiant CMS dev team"
    s.email = "radiant@radiantcms.org"
    s.summary = 'A no-fluff content management system designed for small teams.'
    s.description = "Radiant is a simple and powerful publishing system designed for small teams.\nIt is built with Rails and is similar to Textpattern or MovableType, but is\na general purpose content managment system--not merely a blogging engine."
    s.homepage = 'http://radiantcms.org'
    s.rubyforge_project = RUBY_FORGE_PROJECT
    s.platform = Gem::Platform::RUBY
    s.bindir = 'bin'
    s.executables = (Dir['bin/*'] + Dir['scripts/*']).map { |file| File.basename(file) } 
    s.add_dependency 'rake', '>= 0.8.3'
    s.add_dependency 'rack', '~> 1.1.0' # No longer bundled in actionpack
    s.add_dependency 'compass', '~> 0.10.4'
    s.add_dependency 'will_paginate', '~> 2.3.11'
    s.add_dependency 'RedCloth', '>=4.0.0'
    s.has_rdoc = true
    s.rdoc_options << '--title' << RDOC_TITLE << '--line-numbers' << '--main' << 'README'
    rdoc_excludes = Dir["**"].reject { |f| !File.directory? f }
    rdoc_excludes.each do |e|
      s.rdoc_options << '--exclude' << e
    end
    s.extra_rdoc_files = RDOC_EXTRAS
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
    # Read .gitignore from plugins and exclude those files
    Dir['vendor/plugins/*/.gitignore'].each do |gi|
      dirname = File.dirname(gi)
      File.readlines(gi).each do |i|
        files.exclude "#{dirname}/**/#{i}"
      end
    end
    s.files = files.to_a
  end

  Rake::GemPackageTask.new(spec) do |pkg|
    pkg.need_zip = true
    pkg.need_tar = true
  end

  task :gemspec do
    File.open('radiant.gemspec', 'w') {|f| f.write spec.to_ruby }
  end

  namespace :gem do
    desc "Uninstall Gem"
    task :uninstall do
      sudo = "sudo " if ENV['SUDO'] == 'true'
      sh "#{sudo}gem uninstall #{PKG_NAME}" rescue nil
    end

    desc "Build and install Gem from source"
    task :install => [:gemspec, :package, :uninstall] do
      chdir("#{RADIANT_ROOT}/pkg") do
        latest = Dir["#{PKG_NAME}-*.gem"].last
        sudo = "sudo " if ENV['SUDO'] == 'true'
        sh "#{sudo}gem install #{latest}"
      end
    end
  end

  task :gem => [ :generate_cached_assets ]

  desc "Generates cached assets from source files"
  task :generate_cached_assets do
    TaskSupport.cache_admin_js
  end

  desc "Publish the release files to RubyForge."
  task :release => [:gem, :package] do
    files = ["gem", "tgz", "zip"].map { |ext| "pkg/#{PKG_FILE_NAME}.#{ext}" }
    release_id = nil
    system %{rubyforge login}
    files.each_with_index do |file, idx|
      if idx == 0
        cmd = %Q[rubyforge add_release #{RELEASE_NOTES}#{RELEASE_CHANGES} --preformatted #{RUBY_FORGE_GROUPID} #{RUBY_FORGE_PACKAGEID} "#{RELEASE_NAME}" #{file}]
        puts cmd
        system cmd
      else
        release_id ||= begin
          puts "rubyforge config #{RUBY_FORGE_PROJECT}"
          system "rubyforge config #{RUBY_FORGE_PROJECT}"
          `cat ~/.rubyforge/auto-config.yml | grep "#{RELEASE_NAME}"`.strip.split(/:/).last.strip
        end
        cmd = %Q[rubyforge add_file #{RUBY_FORGE_GROUPID} #{RUBY_FORGE_PACKAGEID} #{release_id} #{file}]
        puts cmd
        system cmd
      end
    end
  end
end

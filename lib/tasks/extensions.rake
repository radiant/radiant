require 'rake/testtask'

namespace :db do
  namespace :migrate do
    desc "Run all Radiant extension migrations"
    task :extensions => :environment do
      require 'radiant/extension_migrator'
      Radiant::ExtensionMigrator.migrate_extensions
      Rake::Task['db:schema:dump'].invoke
    end
  end
  namespace :remigrate do
    desc "Migrate down and back up all Radiant extension migrations"
    task :extensions => :environment do
      require 'highline/import'
      if agree("This task will destroy any data stored by extensions in the database. Are you sure you want to \ncontinue? [yn] ")
        require 'radiant/extension_migrator'
        Radiant::Extension.descendants.each {|ext| ext.migrator.migrate(0) }
        Rake::Task['db:migrate:extensions'].invoke
        Rake::Task['db:schema:dump'].invoke
      end
    end
  end
end

namespace :test do
  desc "Runs tests on all available Radiant extensions, pass EXT=extension_name to test a single extension"
  task :extensions => "db:test:prepare" do
    extensions = Radiant.configuration.enabled_extensions
    if ENV["EXT"]
      extensions = extensions & [ENV["EXT"].to_sym]
      if extensions.empty?
        puts "Sorry, that extension is not installed."
      end
    end
    extensions.each do |extension|
      directory = Radiant::ExtensionPath.for(extension)
      if File.directory?(File.join(directory, 'test'))
        chdir directory do
          if RUBY_PLATFORM =~ /win32/
            system "rake.cmd test RADIANT_ENV_FILE=#{RAILS_ROOT}/config/environment"
          else
            system "rake test RADIANT_ENV_FILE=#{RAILS_ROOT}/config/environment"
          end
        end
      end
    end
  end
end

namespace :spec do
  desc "Runs specs on all available Radiant extensions, pass EXT=extension_name to test a single extension"
  task :extensions => "db:test:prepare" do
    extensions = Radiant.configuration.enabled_extensions
    if ENV["EXT"]
      extensions = extensions & [ENV["EXT"].to_sym]
      if extensions.empty?
        puts "Sorry, that extension is not installed."
      end
    end
    extensions.each do |extension|
      directory = Radiant::ExtensionPath.for(extension)
      if File.directory?(File.join(directory, 'spec'))
        puts %{\nRunning specs on #{extension} extension from #{directory}/spec\n}
        chdir directory do
          if RUBY_PLATFORM =~ /win32/
            system "rake.cmd spec RADIANT_ENV_FILE=#{RAILS_ROOT}/config/environment"
          else
            system "rake spec RADIANT_ENV_FILE=#{RAILS_ROOT}/config/environment"
          end
        end
      end
    end
  end
end

namespace :radiant do
  namespace :extensions do
    desc "Runs update asset task for all extensions"
    task :update_all => [:environment] do
      extension_update_tasks = Radiant.configuration.enabled_extensions.map { |n| "radiant:extensions:#{n}:update" }.select { |t| Rake::Task.task_defined?(t) }
      extension_update_tasks.each {|t| Rake::Task[t].invoke }
    end
  end
end

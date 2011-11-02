namespace :db do
  desc "Migrate schema to version 0 and back up again. WARNING: Destroys all data in tables!!"
  task :remigrate => :environment do
    require 'highline/import'
    if ENV['OVERWRITE'].to_s.downcase == 'true' or agree("This task will destroy any data in the database. Are you sure you want to \ncontinue? [yn] ")
      
      # Migrate downward
      ActiveRecord::Migrator.migrate("#{RADIANT_ROOT}/db/migrate/", 0)
    
      # Migrate upward 
      Rake::Task["db:migrate"].invoke
      
      # Dump the schema
      Rake::Task["db:schema:dump"].invoke
    else
      say "Task cancelled."
      exit
    end
  end
  
  task :initialize => :environment do    
    require 'highline/import'
    if ENV['OVERWRITE'].to_s.downcase == 'true' or agree("This task will destroy any data in the database. Are you sure you want to \ncontinue? [yn] ")

      # We need to erase and remove all existing radiant tables, but we don't want to 
      # assume that the administrator has access to drop and create the database.
      # Ideally we should also allow for the presence of non-radiant tables, though
      # that's not a setup anyone would recommend.
      #
      ActiveRecord::Base.connection.tables.each do |table|
        ActiveRecord::Migration.drop_table table
      end
      Rake::Task["db:migrate"].invoke
    else
      say "Task cancelled."
      exit
    end
  end
  
  desc "Bootstrap your database for Radiant."
  task :bootstrap => :initialize do
    require 'radiant/setup'
    Radiant::Setup.bootstrap(
      :admin_name => ENV['ADMIN_NAME'],
      :admin_username => ENV['ADMIN_USERNAME'],
      :admin_password => ENV['ADMIN_PASSWORD'],
      :database_template => ENV['DATABASE_TEMPLATE']
    )
    Rake::Task['db:migrate:extensions'].invoke
    Rake::Task['radiant:extensions:update_all'].invoke
    puts %{

Your radiant application is now complete. You can test it by running script/server and directing a web browser to http://localhost:3000/.

To add radiant extensions, just add gem lines to your application's Gemfile and run bundle install again. 

To find radiant extensions, please visit http://ext.radiantcms.org.

}
  end
  
  desc "Migrate the database through all available migration scripts (looks for db/migrate/* in radiant, in extensions and in your site) and update db/schema.rb by invoking db:schema:dump. Turn off output with VERBOSE=false."
  task :migrate => :environment do
    Rake::Task['db:migrate:radiant'].invoke
    Rake::Task['db:migrate:extensions'].invoke
    ActiveRecord::Migration.verbose = ENV["VERBOSE"] ? ENV["VERBOSE"] == "true" : true
    ActiveRecord::Migrator.migrate("db/migrate/", ENV["VERSION"] ? ENV["VERSION"].to_i : nil)
    Rake::Task["db:schema:dump"].invoke if ActiveRecord::Base.schema_format == :ruby
  end

  namespace :migrate do
    desc "Migrates the database through steps defined in the core radiant distribution. Usual db:migrate options can apply."
    task :radiant => :environment do
      ActiveRecord::Migration.verbose = ENV["VERBOSE"] ? ENV["VERBOSE"] == "true" : true
      ActiveRecord::Migrator.migrate(File.join(Radiant.root, 'db', 'migrate'), ENV["VERSION"] ? ENV["VERSION"].to_i : nil)
      Rake::Task["db:schema:dump"].invoke if ActiveRecord::Base.schema_format == :ruby
    end
  end
end
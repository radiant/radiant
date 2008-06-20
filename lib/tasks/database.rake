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
  
  desc "Bootstrap your database for Radiant."
  task :bootstrap => :remigrate do
    require 'radiant/setup'
    Radiant::Setup.bootstrap(
      :admin_name => ENV['ADMIN_NAME'],
      :admin_username => ENV['ADMIN_USERNAME'],
      :admin_password => ENV['ADMIN_PASSWORD'],
      :database_template => ENV['DATABASE_TEMPLATE']
    )
  end
  
  #
  # The following tasks are only needed by Scenarios until Rails 2
  #
  
  desc 'Drops the database for the current RAILS_ENV'
  task :drop => :environment do
    config = ActiveRecord::Base.configurations[RAILS_ENV]
    case config['adapter']
    when 'mysql'
      ActiveRecord::Base.connection.drop_database config['database']
    when /^sqlite/
      FileUtils.rm_f(File.join(RAILS_ROOT, config['database']))
    when 'postgresql'
      `dropdb "#{config['database']}"`
    end
  end
    
  desc 'Create the database defined in config/database.yml for the current RAILS_ENV'
  task :create => :environment do
    config = ActiveRecord::Base.configurations[RAILS_ENV]
    begin
      ActiveRecord::Base.establish_connection(config)
      ActiveRecord::Base.connection
    rescue
      case config['adapter']
      when 'mysql'
        `mysqladmin #{config['password'].nil? ? '' : "-p #{config['password']}"} -u #{config['username']} create #{config['database']}`
      when 'postgresql'
        `createdb "#{config['database']}" -E utf8`
      when 'sqlite'
        `sqlite "#{config['database']}"`
      when 'sqlite3'
        `sqlite3 "#{config['database']}"`
      end
    else
      p "#{config['database']} already exists"
    end
  end
  
  desc "Drops and recreates the database from db/schema.rb for the current environment."
  task :reset => ['db:drop', 'db:create', 'db:schema:load']
end
namespace :db do
  task :migrate => 'db:migrate:radiant'
  
  namespace :migrate do
    task :radiant do
      ActiveRecord::Migrator.migrate(File.join(File.dirname(__FILE__), "..", "..", "db", "migrate"))
    end
  end

  desc "Bootstrap your database for Radiant."
  task :bootstrap => :"db:schema:load" do
    require 'radiant/setup'
    Radiant::Setup.bootstrap(
      :admin_name => ENV['ADMIN_NAME'],
      :admin_username => ENV['ADMIN_USERNAME'],
      :admin_password => ENV['ADMIN_PASSWORD'],
      :database_template => ENV['DATABASE_TEMPLATE']
    )
  end
end

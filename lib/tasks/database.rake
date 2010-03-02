namespace :db do
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

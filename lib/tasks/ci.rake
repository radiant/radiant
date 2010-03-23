namespace :ci do
    
  # default is probably right for integrity.
  desc "Create symlink to database.yml. Set DB_YAML_PATH to set the target of the link. Default is ../../shared/radiant/config/database.yml"
  task :configure do
    dbpath = ENV['DB_YAML_PATH'] || "#{Rails.root}/../../shared/radiant/config/database.yml"
    system("ln -s #{dbpath} #{Rails.root}/config/database.yml") unless File.exist?("#{Rails.root}/config/database.yml")
  end

  desc "Migrate-and-test task suitable for continuous integration"
  task :build do
    RAILS_ENV = ENV['RAILS_ENV'] = 'test'
    ['ci:configure', 'db:migrate', 'cucumber:ok', 'spec'].each do |task|
      Rake::Task[task].invoke
    end
  end
end
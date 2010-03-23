namespace :integrity do
    
  # on the CI server the location of radiant will be /path/to/integrity/builds/[x]/
  # put your database.yml in /path/to/integrity/shared/radiant/config/database.yml
  desc "Link to database.yml in integrity/shared/radiant"
  task :configure do
    system("ln -s #{Rails.root}/../../shared/radiant/config/database.yml #{Rails.root}/config/database.yml") unless File.exist?("#{Rails.root}/config/database.yml")
  end

  desc "Migrate, build and test task suitable for continuous integration"
  task :build do
    RAILS_ENV = ENV['RAILS_ENV'] = 'test'
    ['integrity:configure', 'db:migrate', 'cucumber:ok', 'spec'].each do |task|
      Rake::Task[task].invoke
    end
  end
end
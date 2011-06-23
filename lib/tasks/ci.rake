namespace :ci do
  desc "Migrate-and-test task suitable for continuous integration."
  task :build do
    RAILS_ENV = ENV['RAILS_ENV'] = 'test'
    ['db:test:load', 'db:migrate:extensions', 'cucumber:ok', 'spec'].each do |task|
      Rake::Task[task].invoke
    end
  end
end
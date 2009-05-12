$:.unshift(RAILS_ROOT + '/vendor/plugins/cucumber/lib')
begin
  require 'cucumber/rake/task'
  Cucumber::Rake::Task.new(:features) do |t|
    t.cucumber_opts = "--format pretty #{RADIANT_ROOT}/features"
  end
  task :features => 'db:test:prepare'
rescue LoadError
  task :features do
    puts "Required dependency Cucumber is missing.\nRun 'rake gems:install RAILS_ENV=test'"
  end
end
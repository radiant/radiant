$LOAD_PATH.unshift(RAILS_ROOT + '/vendor/plugins/cucumber/lib') if File.directory?(RAILS_ROOT + '/vendor/plugins/cucumber/lib')

begin
  require 'cucumber/version'
  require 'cucumber/rake/task'

  Cucumber::Rake::Task.new(:features) do |t|
    minor = Cucumber::VERSION::MINOR.to_i
    tiny = Cucumber::VERSION::TINY.to_i
    raise LoadError if (minor < 3) || (minor == 3 && tiny < 9)
    t.fork = true
    t.cucumber_opts = ['--format', (ENV['CUCUMBER_FORMAT'] || 'pretty')]
    t.feature_pattern = "#{RADIANT_ROOT}/features/**/*.feature"
  end
  task :features => 'db:test:prepare'
rescue LoadError
  desc 'Cucumber rake task not available'
  task :features do
    abort 'Cucumber rake task is not available. Be sure to install cucumber version 0.3.9 as a gem or plugin'
  end
end

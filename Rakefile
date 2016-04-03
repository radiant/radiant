require 'rubygems'
require 'bundler/setup'
require 'combustion'

# Dir["#{RADIANT_ROOT}/lib/tasks/**/*.rake"].sort.each { |taskfile| load taskfile }
# Radiant::ExtensionPath.rake_task_paths.each { |taskfile| load taskfile }

# APP_RAKEFILE = File.expand_path("../spec/internal/Rakefile", __FILE__)
# load 'rails/tasks/engine.rake'

require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new(:spec)
task default: :spec

Bundler::GemHelper.install_tasks
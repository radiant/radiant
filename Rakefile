# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require File.expand_path('../config/application', __FILE__)
require 'rake'

Rails::Application.load_tasks

unless Rake::Task.task_defined? "radiant:release"
  Dir["#{RADIANT_ROOT}/lib/tasks/**/*.rake"].sort.each { |taskfile| load taskfile }
  Radiant::ExtensionPath.rake_task_paths.each { |taskfile| load taskfile }
end
require File.join(File.dirname(__FILE__), 'config', 'boot')

require 'rake'
require 'rake/testtask'
require 'rdoc/task'

require 'tasks/rails'

unless Rake::Task.task_defined? "radiant:release"
  Dir["#{RADIANT_ROOT}/lib/tasks/**/*.rake"].sort.each { |taskfile| load taskfile }
  Radiant::ExtensionPath.rake_task_paths.each { |taskfile| load taskfile }
end
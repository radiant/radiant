require File.expand_path("#{File.dirname(__FILE__)}/testing/environment")

TESTING_ENVIRONMENTS["rspec_3119_rails_8375"].load
require 'rake/rdoctask'
require 'rake/testtask'
require "spec/rake/spectask"

spec_tasks = []
test_tasks = []
TESTING_ENVIRONMENTS.each do |env|
  namespace env.name do
    env.databases.each do |database|
      
      namespace database do
        task :prepare do
          content = %Q{TESTING_ENVIRONMENT = '#{env.name}'\nDATABASE_ADAPTER = '#{database}'}
          File.open("#{SUPPORT_TEMP}/environment.rb", "w") {|f| f.puts content}
          puts content
        end
        
        if env.name =~ /^rspec/ # We can't use rspec if the environment doesn't support it
          desc "Run specs in environment '#{env.name}' using database '#{database}'"
          Spec::Rake::SpecTask.new(:spec => "#{env.name}:#{database}:prepare") do |t|
            t.fail_on_error = false
            t.spec_opts = ['--options', "\"#{SPEC_ROOT}/spec.opts\""]
            t.spec_files = FileList["#{SUPPORT_TEMP}/environment.rb", "#{SPEC_ROOT}/**/*_spec.rb"]
            t.verbose = false
          end
          spec_tasks << "#{env.name}:#{database}:spec"
        end
        
        desc "Run tests in environment '#{env.name}' using database '#{database}'"
        Rake::TestTask.new(:test => "#{env.name}:#{database}:prepare") do |t|
          t.test_files = FileList["#{SUPPORT_TEMP}/environment.rb", "test/**/*_test.rb"]
          t.verbose = false
        end
        test_tasks << "#{env.name}:#{database}:test"
        
      end
    end
  end
end

desc "Run specs in all environments"
task :spec do
  spec_tasks.each do |task|
    system "rake '#{task}'"
  end
end

desc "Run tests in all environments"
task :test do
  test_tasks.each do |task|
    system "rake '#{task}'"
  end
end

Rake::RDocTask.new(:doc) do |r|
  r.title = "Rails Scenarios Plugin"
  r.main = "README"
  r.options << "--line-numbers"
  r.rdoc_files.include("README", "LICENSE", "lib/**/*.rb")
  r.rdoc_dir = "doc"
end

task :default => [:spec, :test]
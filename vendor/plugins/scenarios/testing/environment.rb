unless defined?(PLUGIN_ROOT)
  require File.dirname(__FILE__) + "/library"
  
  PLUGIN_ROOT         = File.expand_path(File.dirname(__FILE__) + "/..")
  RAILS_ROOT          = PLUGIN_ROOT
  TESTING_ROOT        = "#{PLUGIN_ROOT}/testing"
  SUPPORT_TEMP        = "#{TESTING_ROOT}/tmp"
  SUPPORT_LIB         = "#{SUPPORT_TEMP}/lib"
  SPEC_ROOT           = "#{PLUGIN_ROOT}/spec"
  TEST_ROOT           = "#{PLUGIN_ROOT}/test"
  DB_CONFIG_FILE      = "#{TESTING_ROOT}/database.yml"
  DB_SCHEMA_FILE      = "#{TESTING_ROOT}/schema.rb"
  
  DATABASE_ADAPTER    = "mysql" unless defined?(DATABASE_ADAPTER)
  TESTING_ENVIRONMENT = "rspec_3119_rails_8375" unless defined?(TESTING_ENVIRONMENT)
  
  TESTING_ENVIRONMENTS = []
  def TESTING_ENVIRONMENTS.[](name)
    self.detect {|e| e.name == name}
  end
  
  rails_package = lambda do |pkg|
    pkg.add_library "activesupport", :requires => "active_support"
    pkg.add_library "activerecord",  :requires => "active_record"
    pkg.add_library "actionpack",    :requires => %w(action_controller action_view)
    pkg.after_load { ActiveRecord::Base.logger = RAILS_DEFAULT_LOGGER }
  end
  rspec_package = lambda do |pkg|
    pkg.add_library "rspec"
    pkg.add_library("rspec_on_rails", :after_update => lambda do |lib|
      system "cd #{lib.support_directory} && patch -p0 < #{File.join(TESTING_ROOT, "rspec_on_rails_3119.patch")}"
    end)
  end
  
  # If you change this, you will need to change the Rakefile, as we are depending on the definition of Spectask from here
  TESTING_ENVIRONMENTS << TestingLibrary::Environment.new("rspec_3119_rails_8375", SUPPORT_TEMP, DB_CONFIG_FILE, DB_SCHEMA_FILE) do |env|
    env.package "rails", "http://svn.rubyonrails.org/rails", "trunk", "8375", &rails_package
    env.package "rspec", "http://rspec.rubyforge.org/svn",   "trunk", "3119", &rspec_package
  end
  TESTING_ENVIRONMENTS << TestingLibrary::Environment.new("rspec_3119_rails_1_2_6", SUPPORT_TEMP, DB_CONFIG_FILE, DB_SCHEMA_FILE) do |env|
    env.package "rails", "http://svn.rubyonrails.org/rails", "tags/rel_1-2-6", &rails_package
    env.package "rspec", "http://rspec.rubyforge.org/svn", "trunk", "3119", &rspec_package
  end
  TESTING_ENVIRONMENTS << TestingLibrary::Environment.new("testunit_rails_trunk", SUPPORT_TEMP, DB_CONFIG_FILE, DB_SCHEMA_FILE) do |env|
    env.package "rails", "http://svn.rubyonrails.org/rails", "trunk", &rails_package
  end
  
  $: << "#{TESTING_ROOT}"
  $: << "#{PLUGIN_ROOT}/lib"
  
  require 'logger'
  RAILS_DEFAULT_LOGGER = Logger.new("#{SUPPORT_TEMP}/test.log")
  RAILS_DEFAULT_LOGGER.level = Logger::DEBUG
end

def start_debugger
  begin
    require 'rubygems'
    require_library_or_gem 'ruby-debug'
    Debugger.start
    Debugger.settings[:autoeval] = true
    Debugger.settings[:autolist] = true
    puts "=> Debugger enabled"
  rescue Exception
    puts "You need to install ruby-debug to run the server in debugging mode. With gems, use 'gem install ruby-debug'"
    exit
  end
end
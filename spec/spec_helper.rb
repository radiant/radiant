unless defined? SPEC_ROOT
  ENV["RAILS_ENV"] = "test"
  
  SPEC_ROOT = File.expand_path(File.dirname(__FILE__))
  
  unless defined? RADIANT_ROOT
    if env_file = ENV["RADIANT_ENV_FILE"]
      require env_file
    else
      require File.expand_path(SPEC_ROOT + "/../config/environment")
    end
  end
  require 'spec'
  require 'spec/rails'
  require 'dataset'
  require 'spec/integration'
  
  module Kernel
    def rputs(*args)
      puts *["<pre>", args.collect {|a| CGI.escapeHTML(a.inspect)}, "</pre>"]
    end
  end
  
  class Test::Unit::TestCase
    include Dataset
    datasets_directory "#{RADIANT_ROOT}/spec/datasets"
    Dataset::ContextClassMethods.datasets_database_dump_path = File.expand_path(RAILS_ROOT + '/tmp/dataset')
    
    class << self
      # Class method for test helpers
      def test_helper(*names)
        names.each do |name|
          name = name.to_s
          name = $1 if name =~ /^(.*?)_test_helper$/i
          name = name.singularize
          first_time = true
          begin
            constant = (name.camelize + 'TestHelper').constantize
            self.class_eval { include constant }
          rescue NameError
            filename = File.expand_path(SPEC_ROOT + '/../test/helpers/' + name + '_test_helper.rb')
            require filename if first_time
            first_time = false
            retry
          end
        end
      end    
      alias :test_helpers :test_helper
    end
  end
  
  Dir[RADIANT_ROOT + '/spec/matchers/*_matcher.rb'].each do |matcher|
    require matcher
  end
  
  module Spec
    module Application
      module ExampleExtensions
        def rails_log
          log = IO.read(RAILS_ROOT + '/log/test.log')
          log.should_not be_nil
          log 
        end
      end
      
      module IntegrationExampleExtensions
        def login(user)
          if user.nil?
            get logout_path
          else
            user = users(user) if user.kind_of?(Symbol)
            submit_to login_path, :user => {:login => user.login, :password => "password"}
          end
        end
        
        def current_user
          controller.send :current_user
        end
        
        def encode_credentials(email_password)
          ActionController::HttpAuthentication::Basic.encode_credentials(*email_password)
        end
      end
    end
  end
  
  Spec::Runner.configure do |config|
    config.include Spec::Application::ExampleExtensions
    config.include Spec::Application::IntegrationExampleExtensions, :type => :integration
    
    config.use_transactional_fixtures = true
    config.use_instantiated_fixtures  = false
    config.fixture_path = RAILS_ROOT + '/spec/fixtures/'
    
    # You can declare fixtures for each behaviour like this:
    #   describe "...." do
    #     fixtures :table_a, :table_b
    #
    # Alternatively, if you prefer to declare them only once, you can
    # do so here, like so ...
    #
    #   config.global_fixtures = :table_a, :table_b
    #
    # If you declare global fixtures, be aware that they will be declared
    # for all of your examples, even those that don't use them.
  end
end
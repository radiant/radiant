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
  # require 'spec/integration'

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
    end
  end

  Spec::Runner.configure do |config|
    config.include Spec::Application::ExampleExtensions

    config.use_transactional_fixtures = true
    config.use_instantiated_fixtures  = false
    config.fixture_path = RAILS_ROOT + '/spec/fixtures/'
  end
end
# Configure Rails Envinronment
ENV["RAILS_ENV"] = "test"
require File.expand_path("../dummy/config/environment.rb",  __FILE__)
SPEC_ROOT = File.dirname(__FILE__)

require 'rspec/rails'
require 'rspec/its'
require 'rspec/collection_matchers'
require 'rspec/active_model/mocks'

require 'factory_girl'
FactoryGirl.find_definitions

ENGINE_RAILS_ROOT=File.join(File.dirname(__FILE__), '../')

# Requires supporting ruby files with custom matchers and macros, etc,
# in spec/support/ and its subdirectories.
Dir[File.join(ENGINE_RAILS_ROOT, "spec/support/**/*.rb")].each {|f| require f }
Dir[File.join(ENGINE_RAILS_ROOT, "spec/matchers/**/*.rb")].each {|f| require f }

RSpec.configure do |config|
  config.use_transactional_fixtures = true

  config.infer_spec_type_from_file_location!

  config.before(:each, type: :controller) { @routes = Radiant::Engine.routes }
  config.before(:each, type: :routing)    { @routes = Radiant::Engine.routes }
end

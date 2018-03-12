# Configure Rails Envinronment
ENV["RAILS_ENV"] = "test"
# # require File.expand_path("../internal/config/environment.rb",  __FILE__)
SPEC_ROOT = File.dirname(__FILE__)


require 'rubygems'
require 'bundler/setup'

require 'combustion'

Combustion.initialize! :all

require 'rspec/rails'
require 'rspec/its'
require 'rspec/collection_matchers'
require 'rspec/active_model/mocks'

# Requires supporting ruby files with custom matchers and macros, etc,
# in spec/support/ and its subdirectories.
ENGINE_RAILS_ROOT=File.join(File.dirname(__FILE__), '../')
Dir[File.join(ENGINE_RAILS_ROOT, "spec/support/**/*.rb")].each {|f| require f }
Dir[File.join(ENGINE_RAILS_ROOT, "spec/matchers/**/*.rb")].each {|f| require f }

require 'factory_girl'
FactoryGirl.find_definitions

RSpec.configure do |config|
  config.use_transactional_fixtures = true

  config.infer_spec_type_from_file_location!

  config.include AuthenticationHelper

  config.before(:each, type: :controller) { @routes = Radiant::Engine.routes }
  config.before(:each, type: :routing)    { @routes = Radiant::Engine.routes }
end

def pages(which)
  Page.find_or_create_by(**FactoryGirl.attributes_for(which))
end

def users(which)
  if User.where(login: which).exists?
    User.where(login: which).first
  else
    FactoryGirl.create(which)
  end
end

def page_id(which)
  pages(which).id
end
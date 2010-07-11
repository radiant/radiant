unless defined? SPEC_ROOT
  ENV["RAILS_ENV"] = "test"

  SPEC_ROOT = File.expand_path(File.dirname(__FILE__))

  require File.expand_path("../../config/environment", __FILE__)
  require 'rspec/rails'
  require 'dataset'
  require 'dataset/extensions/rspec'

  Dir["#{Rails.root}/spec/support/**/*.rb"].each {|f| require f}

  RSpec.configure do |config|
    include Spec::Rails::Matchers

    # == Mock Framework
    #
    # If you prefer to use mocha, flexmock or RR, uncomment the appropriate line:
    #
    # config.mock_with :mocha
    # config.mock_with :flexmock
    # config.mock_with :rr
    config.mock_with :rspec

    config.fixture_path = "#{::Rails.root}/spec/fixtures"

    # If you're not using ActiveRecord, or you'd prefer not to run each of your
    # examples within a transaction, comment the following line or assign false
    # instead of true.
    config.use_transactional_fixtures = true
    config.use_instantiated_fixtures  = false
  end
end

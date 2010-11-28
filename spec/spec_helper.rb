unless defined? SPEC_ROOT
  ENV["RAILS_ENV"] = "test"

  SPEC_ROOT = File.expand_path(File.dirname(__FILE__))

  require File.expand_path(File.join(SPEC_ROOT, '../../../', 'config/environment'))
  require 'rspec/rails'
  require 'dataset'
  require 'dataset/extensions/rspec'
  
  Dataset::Resolver.default = Dataset::DirectoryResolver.new("#{SPEC_ROOT}/datasets")
  
  Dir["#{SPEC_ROOT}/support/**/*.rb"].each {|f| require f}

  RSpec.configure do |config|
    include Spec::Rails::Matchers
    
    config.mock_with :rspec
    
    config.fixture_path = "#{::Rails.root}/spec/fixtures"
    
    config.use_transactional_fixtures = true
    config.use_instantiated_fixtures  = false
  end
end

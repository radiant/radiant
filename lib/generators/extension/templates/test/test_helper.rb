require 'test/unit'
# Load the environment
unless defined? RADIANT_ROOT
  ENV["RAILS_ENV"] = "test"
  case
  when ENV["RADIANT_ENV_FILE"]
    require ENV["RADIANT_ENV_FILE"]
  when File.dirname(__FILE__) =~ %r{vendor/radiant/vendor/extensions}
    require "#{File.expand_path(File.dirname(__FILE__) + "/../../../../../../")}/config/environment"
  else
    require "#{File.expand_path(File.dirname(__FILE__) + "/../../../../")}/config/environment"
  end
end
require "#{RADIANT_ROOT}/test/test_helper"

class ActiveSupport::TestCase
  
  # Include a helper to make testing Radius tags easier
  test_helper :extension_tags
  
  # Add the fixture directory to the fixture path
  self.fixture_path << File.dirname(__FILE__) + "/fixtures"
  
  # Add more helper methods to be used by all extension tests here...
  
end
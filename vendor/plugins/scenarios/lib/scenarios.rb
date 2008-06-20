module Scenarios
  # Thrown by Scenario.load when it cannot find a specific senario.
  class NameError < ::NameError; end
  
  class << self
    # The locations from which scenarios will be loaded.
    mattr_accessor :load_paths
    self.load_paths = ["#{RAILS_ROOT}/spec/scenarios", "#{RAILS_ROOT}/test/scenarios", "#{File.dirname(__FILE__)}/scenarios/builtin"]
    
    # Load a scenario by name. <tt>scenario_name</tt> can be a string, symbol,
    # or the scenario class.
    def load(scenario_name)
      klass = scenario_name.to_scenario
      klass.load
      klass
    end
  end
end

# The Scenario namespace makes for Scenario::Base
Scenario = Scenarios

# For Rails 1.2 compatibility
unless Class.instance_methods.include?(:superclass_delegating_reader)
  require File.dirname(__FILE__) + "/scenarios/extensions/delegating_attributes"
end

require 'active_record/fixtures'
require 'scenarios/configuration'
require 'scenarios/table_blasting'
require 'scenarios/table_methods'
require 'scenarios/loading'
require 'scenarios/base'
require 'scenarios/extensions'
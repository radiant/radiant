module Scenarios
  class Base
    class << self
      # Class method to load the scenario. Used internally by the Scenarios
      # plugin.
      def load
        new.load_scenarios(used_scenarios + [self])
      end
      
      # Class method for your own scenario to define helper methods that will
      # be included into the scenario and all specs that include the scenario
      def helpers(&block)
        mod = (const_get(:Helpers) rescue const_set(:Helpers, Module.new))
        mod.module_eval(&block) if block_given?
        mod
      end
      
      # Class method for your own scenario to define the scenarios that it
      # depends on. If your scenario depends on other scenarios those
      # scenarios will be loaded before the load method on your scenario is
      # executed.
      def uses(*scenarios)
        names = scenarios.map(&:to_scenario).reject { |n| used_scenarios.include?(n) }
        used_scenarios.concat(names)
      end
      
      # Class method that returns the scenarios used by your scenario.
      def used_scenarios # :nodoc:
        @used_scenarios ||= []
        @used_scenarios = (@used_scenarios.collect(&:used_scenarios) + @used_scenarios).flatten.uniq
      end
      
      # Returns the scenario class.
      def to_scenario
        self
      end
    end
    
    include TableMethods
    include Loading
    
    attr_reader :table_config
    
    # Initialize a scenario with a Configuration. Used internally by the
    # Scenarios plugin.
    def initialize(config = Configuration.new)
      @table_config = config
      table_config.update_scenario_helpers self.class
      self.extend table_config.table_readers
      self.extend table_config.scenario_helpers
    end
    
    # This method should be implemented in your scenarios. You may also have
    # scenarios that simply use other scenarios, so it is not required that
    # this be overridden.
    def load
    end
    
    # Unload a scenario, sort of. This really only deletes the records, all of
    # them, of every table this scenario modified. The goal is to maintain a
    # clean database for successive runs. Used internally by the Scenarios
    # plugin.
    def unload
      return if unloaded?
      record_metas.each_value { |meta| blast_table(meta.table_name) }
      @unloaded = true
    end
    
    def unloaded?
      @unloaded == true
    end
  end
end
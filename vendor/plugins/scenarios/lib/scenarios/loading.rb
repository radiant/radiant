module Scenarios
  # Provides scenario loading and convenience methods around the Configuration
  # that must be made available through a method _table_config_.
  module Loading # :nodoc:
    def load_scenarios(scenario_classes)
      install_active_record_tracking_hook
      scenario_classes.each do |scenario_class|
        scenario = scenario_class.new(table_config)
        scenario.load
        table_config.loaded_scenarios << scenario
      end if scenario_classes
    end
    
    def loaded_scenarios
      table_config.loaded_scenarios
    end
    
    def scenarios_loaded?
      table_config && table_config.scenarios_loaded?
    end
    
    # The sum of all the loaded scenario's helper methods. These can be mixed
    # into anything you like to gain access to them.
    def scenario_helpers
      table_config.scenario_helpers
    end
    
    # The sum of all the available table reading methods. These will only
    # include readers for which data has been placed into the table. These can
    # be mixed into anything you like to gain access to them.
    def table_readers
      table_config.table_readers
    end
    
    # # This understand nesting descriptions one deep
    # def table_config
    #   on_my_class = self.class.instance_variable_get("@table_config")
    #   return on_my_class if on_my_class
    #   
    #   if self.class.superclass
    #     on_super_class = self.class.superclass.instance_variable_get("@table_config")
    #     return on_super_class if on_super_class
    #   end
    # end
    
    private
      def install_active_record_tracking_hook
        ActiveRecord::Base.table_config = table_config
      end
  end
end
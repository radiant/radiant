$__dataset_top_level = self
module Dataset
  module Extensions # :nodoc:

    module CucumberWorld # :nodoc:
      def dataset(*datasets, &block)
        add_dataset(*datasets, &block)
        
        $__dataset_top_level.Before do
          load = dataset_session.load_datasets_for(self.class)
          extend_from_dataset_load(load)
        end
        
        # Makes sure the datasets are reloaded after each scenario
        self.use_transactional_fixtures = true
      end
    end

  end
end
Cucumber::Rails::World.extend Dataset::Extensions::CucumberWorld
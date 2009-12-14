module Dataset
  module Extensions # :nodoc:
    
    module RSpecExampleGroup # :nodoc:
      def dataset(*datasets, &block)
        add_dataset(*datasets, &block)
        
        load = nil
        before(:all) do
          load = dataset_session.load_datasets_for(self.class)
          extend_from_dataset_load(load)
        end
        before(:each) do
          extend_from_dataset_load(load)
        end
      end
    end
    
  end
end
Spec::Example::ExampleGroup.extend Dataset::Extensions::RSpecExampleGroup
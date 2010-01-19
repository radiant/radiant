module Dataset
  class Session # :nodoc:
    attr_accessor :dataset_resolver
    
    def initialize(database, dataset_resolver = Resolver.default)
      @database = database
      @dataset_resolver = dataset_resolver
      @datasets = Hash.new
      @load_stack = []
    end
    
    def add_dataset(test_class, dataset_identifier)
      dataset = dataset_resolver.resolve(dataset_identifier)
      if dataset.used_datasets
        dataset.used_datasets.each { |used_dataset| self.add_dataset(test_class, used_dataset) }
      end
      datasets_for(test_class) << dataset
    end
    
    def datasets_for(test_class)
      if test_class.superclass
        @datasets[test_class] ||= Collection.new(datasets_for(test_class.superclass) || [])
      end
    end
    
    def load_datasets_for(test_class)
      datasets = datasets_for(test_class)
      @database.clear
      current_load = Load.new(datasets, @database)
      current_load.execute([], @dataset_resolver)
      @load_stack.push(current_load)
      current_load
    end
  end
end
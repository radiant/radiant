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
      if last_load = @load_stack.last
        if last_load.datasets == datasets
          current_load = Reload.new(last_load)
        elsif last_load.datasets.subset?(datasets)
          @database.capture(last_load.datasets)
          current_load = Load.new(datasets, last_load.dataset_binding)
          current_load.execute(last_load.datasets, @dataset_resolver)
          @load_stack.push(current_load)
        else
          @load_stack.pop
          last_load = @load_stack.last
          @database.restore(last_load.datasets) if last_load
          current_load = load_datasets_for(test_class)
        end
      else
        @database.clear
        current_load = Load.new(datasets, @database)
        current_load.execute([], @dataset_resolver)
        @load_stack.push(current_load)
      end
      current_load
    end
  end
end
module Dataset
  class Load # :nodoc:
    attr_reader :datasets, :dataset_binding, :helper_methods
    
    def initialize(datasets, parent_binding)
      @datasets = datasets
      @dataset_binding = SessionBinding.new(parent_binding)
      @helper_methods = Module.new
    end
    
    def execute(loaded_datasets, dataset_resolver)
      (datasets - loaded_datasets).each do |dataset|
        instance = dataset.new
        instance.extend dataset_binding.record_methods
        instance.extend dataset_binding.model_finders
        used_datasets(dataset, dataset_resolver).each do |ds|
          next unless ds.helper_methods
          instance.extend ds.helper_methods
          helper_methods.module_eval do
            include ds.helper_methods
          end
        end
        instance.load
      end
    end
    
    def used_datasets(dataset, dataset_resolver, collector = [])
      dataset.used_datasets.each do |used|
        ds = dataset_resolver.resolve(used)
        used_datasets(ds, dataset_resolver, collector)
        collector << ds
      end if dataset.used_datasets
      collector << dataset
      collector.uniq
    end
  end
  
  class Reload # :nodoc:
    attr_reader :dataset_binding, :load
    delegate :datasets, :helper_methods, :to => :load
    
    def initialize(load)
      @load = load
      @dataset_binding = SessionBinding.new(@load.dataset_binding)
    end
  end
end
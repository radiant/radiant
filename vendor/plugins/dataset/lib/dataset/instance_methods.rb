module Dataset
  module InstanceMethods # :nodoc:
    def extend_from_dataset_load(load)
      load.dataset_binding.install_block_variables(self)
      self.extend load.dataset_binding.record_methods
      self.extend load.dataset_binding.model_finders
      self.extend load.helper_methods
    end
  end
end
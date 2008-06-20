module ActiveRecord
  class Base
    cattr_accessor :table_config
    include Scenarios::TableBlasting
    
    # In order to guarantee that tables are tracked when _create_model_ is
    # used, and those models cause other models to be created...
    def create_with_table_blasting
      prepare_table(self.class.table_name)
      create_without_table_blasting
    end
    alias_method_chain :create, :table_blasting
  end
end
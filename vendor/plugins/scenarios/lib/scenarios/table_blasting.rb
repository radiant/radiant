module Scenarios
  module TableBlasting
    def self.included(base)
      base.module_eval do
        delegate :blasted_tables, :to => :table_config
      end
    end
    
    def blast_table(name) # :nodoc:
      ActiveRecord::Base.silence do
        ActiveRecord::Base.connection.delete "DELETE FROM #{name}", "Scenario Delete"
      end
      blasted_tables << name
    end
    
    def prepare_table(name)
      blast_table(name) unless blasted_tables.include?(name)
    end
  end
end
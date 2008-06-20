module Scenarios
  class Configuration # :nodoc:
    attr_reader :blasted_tables, :loaded_scenarios, :record_metas, :table_readers, :scenario_helpers, :symbolic_names_to_id
    
    def initialize
      @blasted_tables       = Set.new
      @record_metas         = Hash.new
      @table_readers        = Module.new
      @scenario_helpers     = Module.new
      @symbolic_names_to_id = Hash.new {|h,k| h[k] = Hash.new}
      @loaded_scenarios     = Array.new
    end
    
    # Given a created record (currently ScenarioModel or ScenarioRecord),
    # update the table readers module appropriately such that this record and
    # it's id are findable via methods like 'people(symbolic_name)' and
    # 'person_id(symbolic_name)'.
    def update_table_readers(record)
      ids, record_meta = symbolic_names_to_id, record.record_meta # scoping assignments
      
      ids[record_meta.table_name][record.symbolic_name] = record.id
      table_readers.send :define_method, record_meta.id_reader do |*symbolic_names|
        record_ids = symbolic_names.flatten.collect do |symbolic_name|
          if symbolic_name.kind_of?(ActiveRecord::Base)
            symbolic_name.id
          else
            record_id = ids[record_meta.table_name][symbolic_name.to_sym]
            raise ActiveRecord::RecordNotFound, "No object is associated with #{record_meta.table_name}(:#{symbolic_name})" unless record_id
            record_id
          end
        end
        record_ids.size > 1 ? record_ids : record_ids.first
      end
      
      table_readers.send :define_method, record_meta.record_reader do |*symbolic_names|
        results = symbolic_names.flatten.collect do |symbolic_name|
          symbolic_name.kind_of?(ActiveRecord::Base) ?
            symbolic_name :
            record_meta.record_class.find(send(record_meta.id_reader, symbolic_name))
        end
        results.size > 1 ? results : results.first
      end
    end
    
    def update_scenario_helpers(scenario_class)
      scenario_helpers.module_eval do
        include scenario_class.helpers
      end
    end
    
    def scenarios_loaded?
      !loaded_scenarios.blank?
    end
  end
end
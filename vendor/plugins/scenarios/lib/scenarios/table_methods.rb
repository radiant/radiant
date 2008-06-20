module Scenarios
  # This helper module contains the #create_record method. It is made
  # available to all Scenario instances, test and example classes, and test
  # and example instances.
  module TableMethods
    include TableBlasting
    
    delegate :record_metas, :to => :table_config
    
    # Insert a record into the database, add the appropriate helper methods
    # into the scenario and spec, and return the ID of the inserted record:
    #
    #   create_record :event, :name => "Ruby Hoedown"
    #   create_record Event, :hoedown, :name => "Ruby Hoedown"
    #
    # The first form will create a new record in the given class identifier
    # and no symbolic name (essentially).
    #
    # The second form is exactly like the first, except for that it provides a
    # symbolic name as the second parameter. The symbolic name will allow you
    # to access the record through a couple of helper methods:
    #
    #   events(:hoedown)    # The hoedown event
    #   event_id(:hoedown)  # The ID of the hoedown event
    #
    # These helper methods are only accessible for a particular table after
    # you have inserted a record into that table using <tt>create_record</tt>.
    def create_record(class_identifier, *args)
      insert(ScenarioRecord, class_identifier, *args) do |record|
        meta = record.record_meta
        fixture = record.to_fixture
        begin
          meta.connection.insert_fixture(fixture, record.record_meta.table_name)
        rescue # Rails 1.2 compatible!
          meta.connection.execute "INSERT INTO #{meta.table_name} (#{fixture.key_list}) VALUES (#{fixture.value_list})"
        end
        record.id
      end
    end
    
    # Instantiate and save! a model, add the appropriate helper methods into
    # the scenario and spec, and return the new model instance:
    #
    #   create_model :event, :name => "Ruby Hoedown"
    #   create_model Event, :hoedown, :name => "Ruby Hoedown"
    #
    # The first form will create a new model with no symbolic name
    # (essentially).
    #
    # The second form is exactly like the first, except for that it provides a
    # symbolic name as the second parameter. The symbolic name will allow you
    # to access the record through a couple of helper methods:
    #
    #   events(:hoedown)    # The hoedown event
    #   event_id(:hoedown)  # The ID of the hoedown event
    #
    # These helper methods are only accessible for a particular table after
    # you have inserted a record into that table using <tt>create_model</tt>.
    def create_model(class_identifier, *args)
      insert(ScenarioModel, class_identifier, *args) do |record|
        model = record.to_model
        model.save!
        model
      end
    end
    
    private
      def insert(record_or_model, class_identifier, *args, &insertion)
        symbolic_name, attributes = extract_creation_arguments(args)
        record_meta  = (record_metas[class_identifier] ||= RecordMeta.new(class_identifier))
        record       = record_or_model.new(record_meta, attributes, symbolic_name)
        return_value = nil
        ActiveRecord::Base.silence do
          prepare_table(record_meta.table_name)
          return_value = insertion.call record
          table_config.update_table_readers(record)
          self.extend table_config.table_readers
        end
        return_value
      end
      
      def extract_creation_arguments(arguments)
        if arguments.size == 2 && arguments.last.kind_of?(Hash)
          arguments
        elsif arguments.size == 1 && arguments.last.kind_of?(Hash)
          [nil, arguments[0]]
        else
          [nil, Hash.new]
        end
      end
      
      class RecordMeta # :nodoc:
        attr_reader :class_name, :record_class, :table_name
        
        def initialize(class_identifier)
          @class_identifier = class_identifier
          @class_name       = resolve_class_name(class_identifier)
          @record_class     = class_name.constantize
          @table_name       = record_class.table_name
        end
        
        def timestamp_columns
          @timestamp_columns ||= begin
            timestamps = %w(created_at created_on updated_at updated_on)
            columns.select do |column|
              timestamps.include?(column.name)
            end
          end
        end

        def columns
          @columns ||= connection.columns(table_name)
        end
        
        def connection
          record_class.connection
        end
        
        def id_reader
          @id_reader ||= begin
            reader = ActiveRecord::Base.pluralize_table_names ? table_name.singularize : table_name
            "#{reader}_id".to_sym
          end
        end
        
        def record_reader
          table_name.to_sym
        end
        
        def resolve_class_name(class_identifier)
          case class_identifier
          when Symbol
            class_identifier.to_s.singularize.camelize
          when Class
            class_identifier.name
          when String
            class_identifier
          end
        end
        
        def to_s
          "#<RecordMeta: #{table_name}>"
        end
      end
      
      class ScenarioModel # :nodoc:
        attr_reader :attributes, :model, :record_meta, :symbolic_name
        delegate :id, :to => :model
        
        def initialize(record_meta, attributes, symbolic_name = nil)
          @record_meta   = record_meta
          @attributes    = attributes.stringify_keys
          @symbolic_name = symbolic_name || object_id
        end
        
        def to_hash
          to_model.attributes
        end
        
        def to_model
          @model ||= record_meta.record_class.new(attributes)
        end
      end
      
      class ScenarioRecord # :nodoc:
        attr_reader :record_meta, :symbolic_name
        
        def initialize(record_meta, attributes, symbolic_name = nil)
          @record_meta   = record_meta
          @attributes    = attributes.stringify_keys
          @symbolic_name = symbolic_name || object_id
          
          install_default_attributes!
        end
        
        def id
          @attributes['id']
        end
        
        def to_hash
          @attributes
        end
        
        def to_fixture
          Fixture.new(to_hash, record_meta.class_name)
        end
        
        def install_default_attributes!
          @attributes['id'] ||= symbolic_name.to_s.hash.abs
          install_timestamps!
        end
        
        def install_timestamps!
          record_meta.timestamp_columns.each do |column|
            @attributes[column.name] = now(column) unless @attributes.key?(column.name)
          end
        end
        
        def now(column)
          now = ActiveRecord::Base.default_timezone == :utc ? column.klass.now.utc : column.klass.now
          now.to_s(:db)
        end
      end
  end
end
require 'active_record/fixtures'

module Dataset
  module Record # :nodoc:
    
    class Fixture # :nodoc:
      attr_reader :meta, :symbolic_name, :session_binding
      
      def initialize(meta, attributes, symbolic_name, session_binding)
        @meta            = meta
        @attributes      = attributes.stringify_keys
        @symbolic_name   = symbolic_name || object_id
        @session_binding = session_binding
        
        install_default_attributes!
      end
      
      def create
        record_class.connection.insert_fixture to_fixture, meta.table_name
        id
      end
      
      def id
        @attributes['id']
      end
      
      def record_class
        meta.record_class
      end
      
      def to_fixture
        ::Fixture.new(to_hash, meta.class_name)
      end
      
      def to_hash
        hash = @attributes.dup
        hash[meta.inheritance_column] = meta.sti_name if meta.inheriting_record?
        record_class.reflections.each do |name, reflection|
          name = name.to_s
          add_reflection_attributes(hash, name, reflection) if hash[name]
        end
        hash
      end
      
      def install_default_attributes!
        @attributes['id'] ||= symbolic_name.to_s.hash.abs
        install_timestamps!
      end
      
      def install_timestamps!
        meta.timestamp_columns.each do |column|
          @attributes[column.name] = now(column) unless @attributes.key?(column.name)
        end
      end
      
      def now(column)
        (ActiveRecord::Base.default_timezone == :utc ? Time.now.utc : Time.now).to_s(:db)
      end
      
      private
        def add_reflection_attributes(hash, name, reflection)
          value = hash.delete(name)
          case value
          when Symbol
            hash[reflection.primary_key_name] = session_binding.find_id(reflection.klass, value)
          else
            hash[reflection.primary_key_name] = value
          end
        end
    end
    
  end
end
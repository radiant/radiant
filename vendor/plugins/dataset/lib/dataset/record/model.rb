module Dataset
  module Record # :nodoc:
    
    class Model # :nodoc:
      attr_reader :attributes, :model, :meta, :symbolic_name, :session_binding
      
      def initialize(meta, attributes, symbolic_name, session_binding)
        @meta            = meta
        @attributes      = attributes.stringify_keys
        @symbolic_name   = symbolic_name || object_id
        @session_binding = session_binding
      end
      
      def record_class
        meta.record_class
      end
      
      def id
        model.id
      end
      
      def create
        model = to_model
        model.save!
        model
      end
      
      def to_hash
        to_model.attributes
      end
      
      def to_model
        @model ||= begin
          m = meta.record_class.new
          attributes.each do |k,v|
            if reflection = record_class.reflect_on_association(k.to_sym)
              case v
              when Symbol
                v = session_binding.find_model(reflection.klass, v)
              end
            end
            m.send "#{k}=", v
          end
          m
        end
      end
    end
    
  end
end
module InheritableClassAttributes
  def self.included(base)
    base.extend ClassMethods
    base.module_eval do
      class << self
        alias inherited_without_inheritable_class_attributes inherited
        alias inherited inherited_with_inheritable_class_attributes
      end
    end
  end
  
  module ClassMethods
    def inheritable_cattr_readers
      @inheritable_class_readers ||= []
    end
    
    def inheritable_cattr_writers
      @inheritable_class_writers ||= []
    end
    
    def cattr_inheritable_reader(*symbols)
      symbols.each do |symbol|
        self.inheritable_cattr_readers << symbol
        self.module_eval %{
          def self.#{symbol}
            @#{symbol}
          end 
        }
      end
      self.inheritable_cattr_readers.uniq!
    end
    
    def cattr_inheritable_writer(*symbols)
      symbols.each do |symbol|
        self.inheritable_cattr_writers << symbol
        self.module_eval %{
          def self.#{symbol}=(value)
            @#{symbol} = value
          end 
        }
      end
      self.inheritable_cattr_writers.uniq!
    end
    
    def cattr_inheritable_accessor(*symbols)
      cattr_inheritable_writer(*symbols)
      cattr_inheritable_reader(*symbols)
    end
    
    def inherited_with_inheritable_class_attributes(klass)
      inherited_without_inheritable_class_attributes(klass) if respond_to?(:inherited_without_inheritable_class_attributes)
      
      readers = inheritable_cattr_readers.dup
      writers = inheritable_cattr_writers.dup
      inheritables = [:inheritable_cattr_readers, :inheritable_cattr_writers]
      
      (readers + writers + inheritables).uniq.each do |attr|
        var = "@#{attr}"
        old_value = self.module_eval(var)
        new_value = (old_value.dup rescue old_value)
        klass.module_eval("#{var} = new_value")
      end
    end
  end
end
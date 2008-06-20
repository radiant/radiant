require 'active_record'

module DefaultOrder
  def self.append_features(base) # :nodoc:
    super
    base.extend ClassMethods
  end
  
  module ClassMethods
    def order_by(order_string)
      self.class_eval %{
        class << self
          def find_with_order(*args)
            if args[1] 
              args[1][:order] = "#{order_string}" if args[1].is_a?(Hash) && !args[1][:order]
            else
              args[1] = {:order => "#{order_string}"}
            end
            find_without_order(*args)
          end
        
          alias_method :find_without_order, :find
          alias_method :find, :find_with_order
        end
      }
    end
  end
end

ActiveRecord::Base.class_eval do
  include DefaultOrder
end
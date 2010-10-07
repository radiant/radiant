module Radiant
  class Config
    class Definition
      attr_reader :default, :type, :label, :validate_with, :select_from, :allow_blank, :allow_display, :allow_change, :error_message
      
      def initialize(options={})
        [:default, :type, :label, :validate_with, :select_from, :allow_blank, :hidden, :error_message].each do |attribute|
          instance_variable_set "@#{attribute}".to_sym, options[attribute]
        end
      end
      
      def boolean?
        type == :boolean
      end
      
      def selector?
        !select_from.blank?   
      end

      def selection
        if selector?
          choices = select_from
          choices = choices.call if choices.respond_to? :call
          if allow_blank?
            if choices.is_a? Array
              choices.unshift ""
            elsif choices.is_a? Hash
              choices[''] ||= ""
            end
          end
          choices
        end
      end
      
      def selected(value)
        if value && selector? && pair = selection.select{|s| s.first == value}
          pair.shift
        end
      end
      
      def validation
        if validate_with.is_a? Proc
          @error_message ||= 'is not valid'
          validate_with
        elsif validate_with == :present
          @error_message ||= 'must not be blank'
          lambda { |value| !value.blank? }
        elsif :type == :integer
          @error_message ||= 'must be a number'
          lambda { |value| !value.empty? && value =~ /\A-?\d+\Z/ }
        end
      end
      
      def selectable?(value)
        !selector? || selection.map(&:first).include?(value)
      end
      
      def allow_blank?
        true unless allow_blank == false
      end
      
      def settable?
        true if allow_change
      end
      
      def hidden?
        true if allow_display == false
      end
      
    end
  end
end
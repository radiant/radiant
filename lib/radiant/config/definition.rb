module Radiant
  class Config
    class Definition
      
      attr_reader :empty, :default, :type, :notes, :validate_with, :select_from, :allow_blank, :allow_display, :allow_change, :units

      # Configuration 'definitions' are metadata held in memory that add restriction and description to individual config entries.
      #
      # By default radiant's configuration machinery is open and ad-hoc: config items are just globally-accessible variables.
      # They're created when first mentioned and then available in all parts of the application. The definition mechanism is a way 
      # to place limits on that behavior. It allows you to protect a config entry, to specify the values it can take and to 
      # validate it when it changes. In the next update it will also allow you to declare that
      # a config item is global or site-specific.
      #
      # The actual defining is done by Radiant::Config#define and usually in a block like this:
      #
      #   Radiant::Config.prepare do |config|
      #     config.namespace('users', :allow_change => true) do |users|
      #       users.define 'allow_password_reset?', :label => 'Allow password reset?'
      #     end
      #   end
      #
      # See the method documentation in Radiant::Config for options and conventions.
      #
      def initialize(options={})
        [:empty, :default, :type, :notes, :validate_with, :select_from, :allow_blank, :allow_change, :allow_display, :units].each do |attribute|
          instance_variable_set "@#{attribute}".to_sym, options[attribute]
        end
      end
      
      # Returns true if the definition included an :empty flag, which should only be the case for the blank, unrestricting
      # definitions created when an undefined config item is set or got.
      #
      def empty?
        !!empty
      end
      
      # Returns true if the definition included a :type => :boolean parameter. Config entries that end in '?' are automatically 
      # considered boolean, whether a type is declared or not. config.boolean? may therefore differ from config.definition.boolean?
      #
      def boolean?
        type == :boolean
      end
      
      # Returns true if the definition included a :select_from parameter (either as list or proc).
      #
      def selector?
        !select_from.blank?   
      end
      
      # Returns true if the definition included a :type => :integer parameter
      def integer?
        type == :integer
      end
      
      # Returns the list of possible values for this config entry in a form suitable for passing to options_for_select.
      # if :select_from is a proc it is called first with no arguments and its return value passed through.
      #
      def selection
        if selector?
          choices = select_from
          choices = choices.call if choices.respond_to? :call
          choices = normalize_selection(choices)
          choices.unshift ["",""] if allow_blank?
          choices
        end
      end
      
      # in definitions we accept anything that options_for_select would normally take
      # here we standardises on an options array-of-arrays so that it's easier to validate input
      #
      def normalize_selection(choices)
        choices = choices.to_a if Hash === choices
        choices = choices.collect{|c| (c.is_a? Array) ? c : [c,c]}
      end
      
      # If the config item is a selector and :select_from specifies [name, value] pairs (as hash or array), 
      # this will return the name corresponding to the currently selected value.
      #
      def selected(value)
        if value && selector? && pair = selection.find{|s| s.last == value}
          pair.first
        end
      end
      
      # Checks the supplied value against the validation rules for this definition.
      # There are several ways in which validations might be defined or implied:
      # * if :validate_with specifies a block, the setting object is passed to the block
      # * if :type is :integer, we test that the supplied string resolves to a valid integer
      # * if the config item is a selector we test that its value is one of the permitted options
      # * if :allow_blank has been set to false, we test that the value is not blank
      #
      def validate(setting)
        if allow_blank?
          return if setting.value.blank?
        else
          setting.errors.add :value, :blank if setting.value.blank?
        end
        if validate_with.is_a? Proc
          validate_with.call(setting)
        end
        if selector?
          setting.errors.add :value, :not_permitted unless selectable?(setting.value)
        end
        if integer?
          Integer(setting.value) rescue setting.errors.add :value, :not_a_number
        end
      end
      
      # Returns true if the value is one of the permitted selections. Not case-sensitive.
      def selectable?(value)
        return true unless selector?
        selection.map(&:last).map(&:downcase).include?(value.downcase)
      end
      
      # Returns true unless :allow_blank has been explicitly set to false. Defaults to true.
      # A config item that does not allow_blank must be set or it will not be valid.
      def allow_blank?
        true unless allow_blank == false
      end
      
      # Returns true unless :allow_change has been explicitly set to false. Defaults to true. 
      # A config item that is not settable cannot be changed in the running application.
      def settable?
        true unless allow_change == false
      end
      
      # Returns true unless :allow_change has been explicitly set to false. Defaults to true.
      # A config item that is not visible cannot be displayed in a radius tag.
      def visible?
        true unless allow_display == false
      end
      
      # Returns true if :allow_display has been explicitly set to false. Defaults to true.
      def hidden?
        true if allow_display == false
      end
      
    end
  end
end


require 'resourceful/builder'

module Resourceful
  module Default
    # This module is mostly meant to be used by the make_resourceful default actions.
    # It provides various methods that declare where callbacks set in the +make_resourceful+ block,
    # like Builder#before and Builder#response_for,
    # should be called.
    module Callbacks
      # Calls any +before+ callbacks set in the +make_resourceful+ block for the given event.
      def before(event)
        resourceful_fire(:before, event.to_sym)
      end

      # Calls any +after+ callbacks set in the +make_resourceful+ block for the given event.
      def after(event)
        resourceful_fire(:after, event.to_sym)
      end

      # Calls any +response_for+ callbacks set in the +make_resourceful+ block for the given event.
      # Note that these aren't called directly,
      # but instead passed along to Rails' respond_to method.
      def response_for(event)
        if responses = self.class.read_inheritable_attribute(:resourceful_responses)[event.to_sym]
          respond_to do |format|
            responses.each do |key, value|
              format.send(key, &scope(value))
            end
          end
        end
      end

      # Returns a block identical to the given block,
      # but in the context of the current controller.
      # The returned block accepts no arguments,
      # even if the given block accepted them.
      def scope(block)
        lambda do
          instance_eval(&(block || lambda {}))
        end
      end

      private

      def resourceful_fire(type, name)
        scope(self.class.read_inheritable_attribute(:resourceful_callbacks)[type][name]).call
      end
    end
  end
end

require 'resourceful/builder'
require 'resourceful/base'

module Resourceful
  # This module is extended by the ActionController::Base class object.
  # It provides the actual +make_resourceful+ method
  # and sets up the controller so that everything will work.
  module Maker
    # Called automatically on ActionController::Base.
    # Initializes various inheritable attributes.
    def self.extended(base)
      base.write_inheritable_attribute :resourceful_callbacks, {}
      base.write_inheritable_attribute :resourceful_responses, {}
      base.write_inheritable_attribute :parents,               []
      base.write_inheritable_attribute :made_resourceful,      false
    end

    # :call-seq:
    #   make_resourceful(options = {}) { ... }
    #
    # This is the central method, and namesake, of make_resourceful.
    # It takes a block and evaluates it in the context of a Builder,
    # allowing the controller to be customized extensively.
    #
    # See Resourceful::Builder for documentation on the methods available
    # in the context of the block.
    #
    # The only option currently available is <tt>:include</tt>.
    # It takes an object that responds to to_proc
    # (or an array of such objects)
    # and evaluates that proc in the same context as the block.
    # For example:
    #
    #   make_resourceful :include => proc { actions :all } do
    #     before :show do
    #       current_object.current_user = current_user
    #     end
    #   end
    #
    # This is the same as:
    #
    #   make_resourceful do
    #     actions :all
    #     before :show do
    #       current_object.current_user = current_user
    #     end
    #   end
    # 
    def make_resourceful(options = {}, &block)
      # :stopdoc:
      include Resourceful::Base
      # :startdoc:

      builder = Resourceful::Builder.new(self)
      unless builder.inherited?
        Resourceful::Base.made_resourceful.each { |proc| builder.instance_eval(&proc) }
      end
      Array(options[:include]).each { |proc| builder.instance_eval(&proc) }
      builder.instance_eval(&block)

      builder.apply

      add_helpers
    end

    # Returns whether or not make_resourceful has been called
    # on this controller or any controllers it inherits from.
    def made_resourceful?
      read_inheritable_attribute(:made_resourceful)
    end

    private

    def add_helpers
      helper_method(:object_path, :objects_path, :new_object_path, :edit_object_path,
                    :object_url, :objects_url, :new_object_url, :edit_object_url,
                    :parent_path, :parent_url,
                    :current_objects, :current_object, :current_model, :current_model_name,
                    :namespaces, :instance_variable_name, :parent_names, :parent_name,
                    :parent?, :parent_model, :parent_object, :save_succeeded?)
    end
  end
end

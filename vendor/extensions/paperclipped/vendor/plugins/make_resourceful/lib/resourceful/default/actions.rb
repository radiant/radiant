module Resourceful
  module Default
    # Contains the definitions of the default resourceful actions.
    # These are made available with the Builder#actions method.
    #
    # These methods are very compact,
    # so the best way to understand them is just to look at their source.
    # Check out Resourceful::Accessors and Resourceful::Callbacks
    # for the documentation of the methods called within the actions.
    #
    # Along with each action is listed the RESTful method
    # which corresponds to the action.
    # The controller in the examples is FoosController,
    # and the id for single-object actions is 12.
    module Actions
      # GET /foos
      def index
        load_objects
        before :index
        response_for :index
      end

      # GET /foos/12
      def show
        load_object
        before :show
        response_for :show
      rescue
        response_for :show_fails
      end

      # POST /foos
      def create
        build_object
        load_object
        before :create
        if current_object.save
          save_succeeded!
          after :create
          response_for :create
        else
          save_failed!
          after :create_fails
          response_for :create_fails
        end
      end

      # PUT /foos/12
      def update
        load_object
        before :update
        if current_object.update_attributes object_parameters
          save_succeeded!
          after :update
          response_for :update
        else
          save_failed!
          after :update_fails
          response_for :update_fails
        end
      end

      # GET /foos/new
      def new
        build_object
        load_object
        before :new
        response_for :new
      end

      # GET /foos/12/edit
      def edit
        load_object
        before :edit
        response_for :edit
      end

      # DELETE /foos/12
      def destroy
        load_object
        before :destroy
        if current_object.destroy
          after :destroy
          response_for :destroy
        else
          after :destroy_fails
          response_for :destroy_fails
        end
      end
    end
  end
end

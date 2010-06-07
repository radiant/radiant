class Admin::ResourceController < ApplicationController
  extend Radiant::ResourceResponses
  
  helper_method :model, :current_object, :models, :current_objects, :model_symbol, :plural_model_symbol, :model_class, :model_name, :plural_model_name
  before_filter :populate_format
  before_filter :load_models, :only => :index
  before_filter :load_model, :only => [:new, :create, :edit, :update, :remove, :destroy]
  after_filter :clear_model_cache, :only => [:create, :update, :destroy]

  cattr_reader :paginated
  cattr_accessor :default_per_page, :will_paginate_options
  
  responses do |r|
    # Equivalent respond_to block for :plural responses:
    # respond_to do |wants|
    #   wants.xml { render :xml => models }
    #   wants.json { render :json => models }
    #   wants.any
    # end
    r.plural.publish(:xml, :json) { render format_symbol => models }

    r.singular.publish(:xml, :json) { render format_symbol => model }
    r.singular.default { redirect_to edit_model_path if action_name == "show" }
    
    r.not_found.publish(:xml, :json) { head :not_found }
    r.not_found.default { announce_not_found; redirect_to :action => "index" }

    r.invalid.publish(:xml, :json) { render format_symbol => model.errors, :status => :unprocessable_entity }
    r.invalid.default { announce_validation_errors; render :action => template_name }

    r.stale.publish(:xml, :json) { head :conflict }
    r.stale.default { announce_update_conflict; render :action => template_name }

    r.create.publish(:xml, :json) { render format_symbol => model, :status => :created, :location => url_for(:format => format_symbol, :id => model) }
    r.create.default { redirect_to continue_url(params) }

    r.update.publish(:xml, :json) { head :ok }
    r.update.default { redirect_to continue_url(params) }

    r.destroy.publish(:xml, :json) { head :deleted }
    r.destroy.default { redirect_to continue_url(params) }
  end

  def index
    response_for :plural
  end

  [:show, :new, :edit, :remove].each do |action|
    class_eval %{
      def #{action}                # def show
        response_for :singular     #   response_for :singular
      end                          # end
    }, __FILE__, __LINE__
  end

  [:create, :update].each do |action|
    class_eval %{
      def #{action}                                       # def create
        model.update_attributes!(params[model_symbol])    #   model.update_attributes!(params[model_symbol])
        response_for :#{action}                           #   response_for :create
      end                                                 # end
    }, __FILE__, __LINE__
  end

  def destroy
    model.destroy
    response_for :destroy
  end
  
  def self.model_class(model_class = nil)
    @model_class ||= (model_class || self.controller_name).to_s.singularize.camelize.constantize
  end

  # call paginate_models to declare that will_paginate should be used in the index view
  # options specified here are accessible in the view by calling will_paginate_options
  # eg.
  #
  # Class MyController < Admin::ResourceController
  #   paginate_models :per_page => 100

  def self.paginate_models(options={})
    @@paginated = true
    @@will_paginate_options = options.slice(:class, :previous_label, :next_label, :inner_window, :outer_window, :separator, :container).merge(:param_name => :p)
    @@default_per_page = options[:per_page]
  end

  # returns a hash of options that can be passed to will_paginate
  # the @pagination_for@ helper method calls @will_paginate_options@ unless other options are supplied.
  #
  # pagination_for(@events)
  
  def will_paginate_options
    self.class.will_paginate_options || {}
  end
  helper_method :will_paginate_options

  # a convenience method that returns true if paginate_models has been called on this controller class
  # and can be used to make display decisions in controller and view
  def paginated?
    self.class.paginated == true
  end
  helper_method :paginated?

  # return a hash of page and per_page that can be used to build a will_paginate collection
  # the per_page figure can be set in several ways:
  # request parameter > declared by paginate_models > default set in config entry @admin.pagination.per_page@ > overall default of 50
  def pagination_parameters
    {
      :page => (params[:p] || 1).to_i, 
      :per_page => (params[:pp] || self.class.default_per_page || Radiant::Config['admin.pagination.per_page'] || 50).to_i
    }
  end

  protected

    def rescue_action(exception)
      case exception
      when ActiveRecord::RecordInvalid
        response_for :invalid
      when ActiveRecord::StaleObjectError
        response_for :stale
      when ActiveRecord::RecordNotFound
        response_for :not_found
      else
        super
      end
    end
    
    def model_class
      self.class.model_class
    end

    def model
      instance_variable_get("@#{model_symbol}") || load_model
    end
    alias :current_object :model
    def model=(object)
      instance_variable_set("@#{model_symbol}", object)
    end
    def load_model
      self.model = if params[:id]
        model_class.find(params[:id])
      else
        model_class.new
      end
    end

    def models
      instance_variable_get("@#{plural_model_symbol}") || load_models
    end
    alias :current_objects :models
    def models=(objects)
      instance_variable_set("@#{plural_model_symbol}", objects)
    end
    def load_models
      self.models = paginated? ? model_class.paginate(pagination_parameters) : model_class.all
    end

    def model_name
      model_class.name
    end
    def plural_model_name
      model_name.pluralize
    end
    alias :models_name :plural_model_name

    def model_symbol
      model_name.underscore.intern
    end
    def plural_model_symbol
      model_name.pluralize.underscore.intern
    end
    alias :models_symbol :plural_model_symbol

    def humanized_model_name
      t(model_name.underscore.downcase)
    end

    def continue_url(options)
      options[:redirect_to] || (params[:continue] ? {:action => 'edit', :id => model.id} : index_page_for_model)
    end
    
    def index_page_for_model
      parts = {:action => "index"}
      if paginated? && model && index = model_class.all.index(model)
        page = (index + 1 / pagination_parameters[:per_page]).to_i
        parts[:page] = page if page && page > 0
      end
      parts
    end

    def edit_model_path
      method = "edit_admin_#{model_name.downcase}_path"
      send method.to_sym, params[:id]
    end

    def announce_validation_errors
      flash.now[:error] = t("resource_controller.validation_errors")
    end

    def announce_removed
      ActiveSupport::Deprecation.warn("announce_removed is no longer encouraged in Radiant 0.9.x.", caller)
      flash[:notice] = t("resource_controller.removed", :humanized_model_name => humanized_model_name)    
    end
    
    def announce_not_found
      flash[:notice] = t("resource_controller.not_found", :humanized_model_name => humanized_model_name)    
    end

    def announce_update_conflict
      flash.now[:error] =  t("resource_controller.update_conflict", :humanized_model_name => humanized_model_name)  
    end

    def clear_model_cache
      Radiant::Cache.clear if defined?(Radiant::Cache)
    end

    def format_symbol
      format.to_sym
    end

    def format
      params[:format] || 'html'
    end
    
    # Assist with user agents that cause improper content-negotiation
    # warn "Remove default HTML format, Accept header no longer used. (#{__FILE__}: #{__LINE__})" if Rails.version !~ /^2\.1/
    def populate_format
      params[:format] ||= 'html' unless request.xhr?
    end
    
    
end

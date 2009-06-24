class Admin::ResourceController < ApplicationController
  extend Radiant::ResourceResponses
  
  helper_method :model, :current_object, :models, :current_objects, :model_symbol, :plural_model_symbol, :model_class, :model_name, :plural_model_name
  before_filter :populate_format
  before_filter :load_models, :only => :index
  before_filter :load_model, :only => [:new, :create, :edit, :update, :remove, :destroy]
  after_filter :clear_model_cache, :only => [:create, :update, :destroy]

  def self.model_class(model_class = nil)
    @model_class ||= (model_class || self.controller_name).to_s.singularize.camelize.constantize
  end

  responses do |r|
    # Equivalent respond_to block for :plural responses:
    # respond_to do |wants|
    #   wants.xml { render :xml => models }
    #   wants.json { render :json => models }
    #   wants.any
    # end
    r.plural.publish(:xml, :json) { render format_symbol => models }

    r.singular.publish(:xml, :json) { render format_symbol => model }
    
    r.not_found.publish(:xml, :json) { head :not_found }
    r.not_found.default { announce_not_found; redirect_to continue_url(params) }

    r.invalid.publish(:xml, :json) { render format_symbol => model.errors, :status => :unprocessable_entity }
    r.invalid.default {  announce_validation_errors; render :action => template_name }

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
        announce_saved                                    #   announce_saved
        response_for :#{action}                           #   response_for :create
      end                                                 # end
    }, __FILE__, __LINE__
  end

  def destroy
    model.destroy
    announce_removed
    response_for :destroy
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
      self.models = model_class.all
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
      model_name.underscore.humanize
    end

    def continue_url(options)
      options[:redirect_to] || (params[:continue] ? {:action => 'edit', :id => model.id} : {:action => "index"})
    end

    def announce_saved(message = nil)
      flash[:notice] = message || t("resource_controller.saved", :humanized_model_name => humanized_model_name)
    end

    def announce_validation_errors
      flash.now[:error] = t("resource_controller.validation_errors")
    end

    def announce_removed
      flash[:notice] = t("resource_controller.removed", :humanized_model_name => humanized_model_name)    
    end
    
    def announce_not_found
      flash[:notice] = "#{humanized_model_name} could not be found."
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

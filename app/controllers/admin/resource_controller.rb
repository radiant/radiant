class Admin::ResourceController < ApplicationController
  attr_accessor :cache
  helper_method :model, :models, :model_symbol, :plural_model_symbol, :model_class, :model_name, :plural_model_name
  before_filter :load_models, :only => :index
  before_filter :load_model, :only => [:new, :create, :edit, :update, :remove, :destroy]
  after_filter :clear_model_cache, :only => [:create, :update, :destroy]
  
  def self.model_class(model_class = nil)
    @model_class ||= (model_class || self.controller_name).to_s.singularize.camelize.constantize
  end

  def initialize
    super
    @cache = ResponseCache.instance
  end

  def index
    default_display_responses
  end

  def show
    default_display_responses
  end

  def new
    default_display_responses
  end

  def edit
    default_display_responses
  end
  
  def create
    model.update_attributes!(params[model_symbol])
    default_modify_responses
  end

  def update
    model.update_attributes!(params[model_symbol])
    default_modify_responses
  end
  
  def destroy
    model.destroy
    default_modify_responses
  end
  
  protected

    def rescue_action(exception)
      case exception
      when ActiveRecord::RecordInvalid
        responses_for_invalid
      when ActiveRecord::StaleObjectError
        responses_for_stale
      else
        super
      end
    end
    
    def template_name
      case self.action_name
      when 'new','create'
        'new'
      when 'edit', 'update'
        'edit'
      when 'remove', 'destroy'
        'remove'
      end
    end
    
    def default_display_responses
      respond_to do |format|
        format.html
        format.xml do
          if action_name == 'index'
            render :xml => models
          else
            render :xml => model
          end
        end
      end
    end
    
    def default_modify_responses
      respond_to do |format|
        format.html do
          if action_name == 'destroy'
            announce_removed
          else
            announce_saved
          end
          redirect_to continue_url(params)
        end
        case action_name
        when 'create'
          format.xml { render :xml => self.model, :status => :created, :location => url_for(:format => :xml, :id => self.model) }
        when 'update'
          format.xml { head :ok }
        when 'destroy'
          format.xml { head :deleted }
        end
      end
    end
    
    def responses_for_invalid
      respond_to do |format|
        format.html do
          announce_validation_errors
          render :action => template_name, :status => :unprocessible_entity
        end
        format.xml { render :xml => self.model_class.errors, :status => :unprocessible_entity }
      end
    end
    
    def responses_for_stale
      respond_to do |format|
        format.html do 
          announce_update_conflict
          render :action => template_name, :status => :conflict
        end
        format.xml { head :conflict }
      end
    end
    
    def model_class
      self.class.model_class
    end

    def model
      instance_variable_get("@#{model_symbol}") || load_model
    end
    def model=(object)
      instance_variable_set("@#{model_symbol}", object)
    end
    def load_model
      self.model =  if params[:id] 
        model_class.find(params[:id]) 
      else
        model_class.new
      end
    end

    def models
      instance_variable_get("@#{plural_model_symbol}") || load_models
    end
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
      options[:redirect_to] || (params[:continue] ? {:id => model.id} : {:action => "index"})
    end

    def announce_saved(message = nil)
      flash[:notice] = message || "#{humanized_model_name} saved below."
    end

    def announce_validation_errors
      flash[:error] = "Validation errors occurred while processing this form. Please take a moment to review the form and correct any input errors before continuing."
    end

    def announce_removed
      flash[:notice] = "#{humanized_model_name} has been deleted."
    end

    def announce_update_conflict
      flash[:error] = "#{humanized_model_name} has been modified since it was last loaded. Changes cannot be saved without potentially losing data."
    end

    def clear_model_cache
      cache.clear
    end
end

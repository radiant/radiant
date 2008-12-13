class Admin::AbstractModelController < ApplicationController
  attr_accessor :cache
  
  def self.inherited(subclass)
    ActiveSupport::Deprecation.warn("'Admin::AbstractModelController' has been deprecated.  Please update '#{subclass.name}' to use Admin::ResourceController.")
  end
  
  def self.model_class(model_class = nil)
    @model_class = model_class.to_s.camelize.constantize unless model_class.nil?
    @model_class
  end
  
  def initialize
    super
    @cache = ResponseCache.instance
  end

  def index
    self.models = model_class.find(:all)
  end

  def new
    self.model = model_class.new
    render :template => "admin/#{ model_symbol }/edit" if handle_new_or_edit_post
  end
  
  def edit
    self.model = model_class.find_by_id(params[:id])
    handle_new_or_edit_post
  end
  
  def remove
    self.model = model_class.find(params[:id])
    if request.post?
      model.destroy
      announce_removed
      redirect_to model_index_url
    end
  end
  
  protected
  
    def model_class
      self.class.model_class
    end
  
    def model
      instance_variable_get("@#{model_symbol}")
    end
    def model=(object)
      instance_variable_set("@#{model_symbol}", object)
    end
    
    def models
      instance_variable_get("@#{plural_model_symbol}")
    end
    def models=(objects)
      instance_variable_set("@#{plural_model_symbol}", objects)
    end
    
    def model_name
      model_class.name
    end
    def plural_model_name
      model_name.pluralize
    end
    
    def model_symbol
      model_name.underscore.intern
    end
    def plural_model_symbol
      model_name.pluralize.underscore.intern
    end
    
    def humanized_model_name
      model_name.underscore.humanize
    end
    
    def model_index_url(params = {})
      send("#{ model_symbol }_index_url", params)
    end
    
    def model_edit_url(params = {})
      send("#{ model_symbol }_edit_url", params)
    end
    
    def continue_url(options)
      options[:redirect_to] || (params[:continue] ? model_edit_url(:id => model.id) : model_index_url)
    end

    def save
      model.save
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
    
    def handle_new_or_edit_post(options = {})
      options.symbolize_keys
      if request.post?
        model.attributes = params[model_symbol]
        begin
          if save
            clear_model_cache
            announce_saved(options[:saved_message])
            redirect_to continue_url(options)
            return false
          else
            announce_validation_errors
          end
        rescue ActiveRecord::StaleObjectError
          announce_update_conflict
        end
      end
      true
    end
end

class Admin::ResourceController < ApplicationController
  attr_accessor :cache
  helper_method :model, :models, :model_symbol, :plural_model_symbol, :model_class, :model_name, :plural_model_name
  
  def self.model_class(model_class = nil)
    @model_class = model_class.to_s.camelize.constantize unless model_class.nil?
    @model_class
  end

  def initialize
    super
    @cache = ResponseCache.instance
  end

  def index
    load_models
  end

  def show
    load_model
  end

  def new
    load_model
  end

  def create
    self.model = model_class.create!(params[model_symbol])
    respond_to do |format|
      format.html do
        announce_saved
        redirect_to continue_url(params)
      end
      format.xml  { render :xml => self.model, :status => :created, :location => url_for(:format => :xml, :id => self.model) }
    end
  rescue ActiveRecord::RecordInvalid
    respond_to do |format|
      format.html do
        announce_validation_errors
        render :action => 'new'
      end
      format.xml { render :xml => self.model_class.errors, :status => :unprocessible_entity }
    end
  end

  def edit
    load_model
  end
  
  def update
    load_model
    model.update_attributes!(params[model_symbol])
    respond_to do |format|
      format.html do
        announce_saved
        redirect_to continue_url(params)
      end
      format.xml { head :ok }
    end
  rescue ActiveRecord::RecordInvalid
    respond_to do |format|
      format.html do
        announce_validation_errors
        render :action => 'edit'
      end
      format.xml { render :xml => self.model_class.errors, :status => :unprocessible_entity }
    end
  rescue ActiveRecord::StaleObjectError
    respond_to do |format|
      format.html do 
        announce_update_conflict
        render :action => 'edit', :status => :conflict
      end
      format.xml { head :conflict }
    end
  end

  def remove
    load_model
  end
  
  def destroy
    load_model.destroy
    respond_to do |format|
      format.html do
        announce_removed
        redirect_to :action => 'index'
      end
      format.xml { head :deleted }
    end
  end
  
  protected

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
      self.model = params[:id] ? model_class.find(params[:id]) : model_class.new
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

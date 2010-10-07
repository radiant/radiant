class Admin::SettingsController < ApplicationController
  before_filter :get_setting, :except => [:index]

  only_allow_access_to :show, :edit, :update,
    :when => [:admin],
    :denied_url => { :controller => 'admin/settings', :action => 'index' },
    :denied_message => 'You must have admin privileges to edit settings.'

  def index
    
  end
  
  def show
    respond_to do |format|
      format.html { }
      format.js { render :layout => false }
    end
  end
  
  def edit
    respond_to do |format|
      format.html { }
      format.js { render :layout => false }
    end
  end
  
  def update  
    @setting.update_attributes!(:value, params[:setting][:value])
    respond_to do |format|
      format.html { render :action => 'show' }
      format.js { render :layout => false, :action => 'show' }
    end
  end

private

  def get_setting
    @setting = Radiant::Config.find(params[:id])
    unless @setting.settable?
      respond_to do |format|
        format.html { 
          flash['error'] = "#{@setting.key} is not settable"
          redirect_to :action => 'index'
        }
        format.js { render :status => 403, :text => "#{@setting.key} is not settable" }
      end
      return false
    end
  end
  
end
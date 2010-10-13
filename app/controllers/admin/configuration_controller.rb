class Admin::ConfigurationController < ApplicationController
  before_filter :initialize_config
  
  only_allow_access_to :show, :edit, :update,
    :when => [:admin],
    :denied_url => { :controller => 'admin/settings', :action => 'index' },
    :denied_message => 'You must have admin privileges to edit site configuration.'

  def show
    @user = current_user
    render
  end
  
  def edit
    render
  end
  
  def update
    if params[:config]
      begin
        Radiant.config.transaction do
          params["config"].each_pair do |key, value|
            @config[key] = Radiant::Config.find_or_create_by_key(key)
            @config[key].value = value      # validation sets errors on @config['key'] that the helper methods will pick up
          end
          redirect_to :action => :show
        end
      rescue ActiveRecord::RecordInvalid => e
        flash[:error] = "Configuration error: please check the form"
        render :action => :edit
      rescue Radiant::Config::ConfigError => e
        flash[:error] = "Configuration error: #{e}"
        render :action => :edit
      end
    end
  end
  
protected

  def initialize_config
    @config = {}
  end
  
end
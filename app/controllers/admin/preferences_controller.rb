class Admin::PreferencesController < ApplicationController
  before_filter :load_user

  def initialize
    @controller_name = 'user'
    @template_name = 'preferences'
  end

  def show
    redirect_to :action => 'edit'
  end

  def edit
    render
  end

  def update
    if valid_params?
      if @user.update_attributes(params[:user])
        redirect_to :action => 'show'
      else
        flash[:error] = 'There was an error updating your preferences.'
        render :action => 'edit'
      end
    else
      announce_bad_data
      render :action => 'edit'
    end
  end

  private

  def load_user
    @user = current_user
  end

  def valid_params?
    hash = (params[:user] || {}).symbolize_keys
    (hash.keys - User.protected_attributes).size == 0
  end

  def announce_bad_data
    flash[:error] = 'Bad form data.'
  end
end

class Admin::PreferencesController < ApplicationController
  before_filter :load_user

  def initialize
    @controller_name = 'user'
    @template_name = 'preferences'
  end

  def show
    set_standard_body_style
    render :edit
  end

  def edit
    render
  end

  def update
    if valid_params?
      if @user.update_attributes(params[:user])
        redirect_to admin_configuration_path
      else
        flash[:error] = t('preferences_controller.error_updating')
        render :edit
      end
    else
      announce_bad_data
      render :edit
    end
  end

  private

  def load_user
    @user = current_user
  end

  def valid_params?
    hash = (params[:user] || {}).symbolize_keys
    (hash.keys - User.unprotected_attributes).size == 0
  end

  def announce_bad_data
    flash[:error] = 'Bad form data.'
  end
end

class Admin::WelcomeController < ApplicationController
  skip_login_required
  before_action :never_cache
  skip_before_action :verify_authenticity_token

  def index
    redirect_to admin_pages_url
  end

  def login
    if request.post?
      @username_or_email = params[:username_or_email]
      user = User.authenticate(@username_or_email, params[:password])
      if user
        self.current_user = user
      else
        announce_invalid_user
      end
    end
    if current_user
      redirect_to (session[:return_to] || welcome_url)
      session[:return_to] = nil
    end
  end

  def logout
    self.current_user = nil
    reset_session
    announce_logged_out
    redirect_to login_url
  end

  private

    def never_cache
      expires_now
    end

    def announce_logged_out
      flash[:notice] = t('welcome_controller.logged_out')
    end

    def announce_invalid_user
      flash.now[:error] = t('welcome_controller.invalid_user')
    end

end

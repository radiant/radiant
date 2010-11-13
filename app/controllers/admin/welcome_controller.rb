class Admin::WelcomeController < ApplicationController

  skip_before_filter :verify_authenticity_token
  
  def index
    redirect_to admin_pages_url
  end
  
end

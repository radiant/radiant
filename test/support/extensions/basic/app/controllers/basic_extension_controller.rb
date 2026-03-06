class BasicExtensionController < ApplicationController
  no_login_required
  
  def routing
    render :text => "You're routing works"
  end
end
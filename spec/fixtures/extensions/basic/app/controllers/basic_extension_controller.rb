class BasicExtensionController < Radiant::ApplicationController
  no_login_required

  def routing
    render text: "You're routing works"
  end
end
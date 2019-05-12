class <%= class_name %>Controller < ApplicationController
  # Remove this line if your controller should only be accessible to users
  # that are logged in:
  no_login_required
<% for action in actions -%>

  def <%= action %>
  end
<% end -%>
end

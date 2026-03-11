class <%= class_name %>Controller < ApplicationController
  # Remove this line if your controller should require login:
  skip_login_required
<% for action in actions -%>

  def <%= action %>
  end
<% end -%>
end

class <%= class_name %>Controller < ApplicationController
  # Remove this line if your controller should only be accessible to users
  # that are logged in:
  no_login_required
<% actions.each do |action| -%>

  def <%= action %>
  end
<% end -%>
end

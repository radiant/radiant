When /^I attempt to remove my own account$/ do
  # Only admins can access users, so we'll assume we're logged in as 'admin'
  id = user_id(:admin)
  visit "/admin/users/#{id}/remove"
end

When /^I attempt to delete my own account$/ do
  # Only admins can access users, so we'll assume we're logged in as 'admin'
  id = user_id(:admin)
  visit "/admin/users/#{id}", :delete
end


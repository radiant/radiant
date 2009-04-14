Given(/^I am logged in as ['"](\w+)['"]$/) do |user|
  visit '/admin/login'
  user = users(user.intern)
  fill_in 'Username', :with => user.login
  fill_in 'Password', :with => 'password'
  click_button 'Login'
end

Given /^there are no pages$/ do
  Page.destroy_all
end

Then /^['"](.*)["'] should be selected for ['"](.*)["']$/ do |value, field|
  select_box = field_labeled(field)
  response.should have_tag("select##{select_box.id}") do
    with_tag('option[selected]', :text => value)
  end
end

When /^I save and open the page$/ do
  save_and_open_page
end

Then /^I should see an error message$/ do
  response.should have_tag('#error')
end

Then /^I should see the form$/ do
  response.should have_tag('form')
end
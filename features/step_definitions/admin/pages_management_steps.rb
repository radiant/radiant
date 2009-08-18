When /^I fill in the "([^\"]*)" content with "([^\"]*)"$/ do |part, content|
  fill_in("part_#{part.to_slug}_content", :with => content)
end

Then /^there should be an? "([^\"]*)" part$/ do |name|
  response.should have_tag("#page_#{name.to_slug}")
  response.should have_tag("#part-#{name.to_slug}")
  response.should have_tag("textarea#part_#{name.to_slug}_content")
end

When /^I edit the "([^\"]*)" page$/ do |name|
  page = pages(name.to_sym)
  visit "/admin/pages/#{page.id}/edit"
end
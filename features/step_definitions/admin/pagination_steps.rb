Then /^I should not see pagination controls$/ do
  response.body.should_not have_tag('div.pagination')
end

Then /^I should not see a depagination link$/ do
  response.body.should_not have_tag('div.depaginate')
end

Then /^I should see pagination controls$/ do
  response.body.should have_tag('div.pagination')
end

Then /^I should see page (\d+) of the results$/ do |p|
  response.body.should have_tag('div.pagination') do
    with_tag("span.current", text: p)
  end
end

Then /^I should see a depagination link$/ do
  response.body.should have_tag("a", href: "/admin/readers?pp=all")
end

Then /^I should mention the request parameters$/ do
  puts "!!  params: #{request.params.inspect}"
  true
end
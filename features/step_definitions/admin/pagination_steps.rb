Given /^There are many snippets$/ do
  100.times do |i|
    Snippet.create(:name => "snippet_#{i}", :content => "This is snippet #{i}")
  end
end

Given /^There are few snippets$/ do
  #
end

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
    with_tag("span.current", :text => p)
  end
end

Then /^I should see a depagination link$/ do
  response.body.should have_tag("a", :text => "show all")
end

Then /^I should mention the request parameters$/ do
  puts "!!  params: #{request.params.inspect}"
  true
end

Then /^I should see all the snippets$/ do
  Snippet.all.each do |snippet|
    response.body.should have_tag('tr.snippet') do
      with_tag("a", :text => snippet.name)
    end
  end
end

Before do
  Radiant::Cache.use_x_sendfile = false
  Radiant::Cache.use_x_accel_redirect = nil
end

Given /^the page cache is clear$/ do
  # No-op until we have Rack::Cache installed
  Radiant::Cache.clear if defined?(Radiant::Cache)
end

When(/^I go to page ['"](.*)['"]$/) do |url|
  visit url
  @old_headers ||= response.headers.dup
end

When(/^I go to page ['"](.*)['"] sending the ([-\w]+)$/) do |url, header_key|
  send_header_key = case header_key
  when 'ETag'
    'If-None-Match'
  when 'Last-Modified'
    'If-Modified-Since'
  end
  get url, {}, send_header_key => @old_headers[header_key]
end

Then /^I should get a (\d+) response code$/ do |code|
  response.response_code.should == code.to_i
end

Then /^I should get the same ([-\w]+) header$/ do |header_key|
  response.headers[header_key].should == @old_headers[header_key]
end

Given /^I have turned on X\-Sendfile headers$/ do
  Radiant::Cache.use_x_sendfile = true
end

Then /^I should get an "([^\"]*)" header in the response$/ do |header_key|
  response.headers.to_hash[header_key].should be
end

Given /^I have turned on X\-Accel\-Redirect headers$/ do
  Radiant::Cache.use_x_accel_redirect = "/cache"
end

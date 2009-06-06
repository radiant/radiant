Before do
  Radiant::Cache.use_x_sendfile = false
  Radiant::Cache.use_x_accel_redirect = nil
end

Given /^the page cache is clear$/ do
  # No-op until we have Rack::Cache installed
  Radiant::Cache.clear if defined?(Radiant::Cache)
end

When(/^I go to page "(.*)"$/) do |url|
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

Then /^I should( not)? get an "([^\"]*)" header in the response$/ do |status, header_key|
  if status.nil?
    response.headers.to_hash[header_key].should_not be_empty
  else
    response.headers.to_hash[header_key].should be_empty
  end
end

Given /^I have turned on X\-Accel\-Redirect headers$/ do
  Radiant::Cache.use_x_accel_redirect = "/cache"
end

Given /^I have page caching (on|off)$/ do |status|
  set_page_cache status
end

Then /^The "([^\"]*)" header should be "([^\"]*)"$/ do |header_key, value|
  response.headers.to_hash[header_key].should =~ Regexp.new(value)
end

def set_page_cache(status)
  Page.class_eval %{
    def cache?
      #{status != 'off'}
    end
  }, __FILE__, __LINE__
end


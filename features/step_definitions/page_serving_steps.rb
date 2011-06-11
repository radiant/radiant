Before do
  Radiant::Cache.use_x_sendfile = false
  Radiant::Cache.use_x_accel_redirect = nil
end

Given /^the page cache is clear$/ do
  # No-op until we have Rack::Cache installed
  Radiant::Cache.clear if defined?(Radiant::Cache)
end

Then /^I should get a (\d+) response code$/ do |code|
  response.response_code.should == code.to_i
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

Then /^the "([^\"]*)" header should be "([^\"]*)"$/ do |header_key, value|
  response.headers.to_hash[header_key].should =~ Regexp.new(value)
end

Then /^the page should render$/ do |text|
  if defined?(Spec::Rails::Matchers)
    response.body.should include(text)
  else
    assert_contain text
  end
end

Then /^the page should not render$/ do |text|
  if defined?(Spec::Rails::Matchers)
    response.body.should_not include(text)
  else
    assert_not_contain text
  end
end

def set_page_cache(status)
  Page.class_eval %{
    def cache?
      #{status != 'off'}
    end
  }, __FILE__, __LINE__
end


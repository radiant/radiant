require File.dirname(__FILE__) + '/../spec_helper'


describe "Serving pages from front-end", :type => :integration do
  dataset :pages_with_layouts

  before :each do
    ResponseCache.defaults[:perform_caching] = true
    ResponseCache.defaults[:directory] = "#{RAILS_ROOT}/tmp/cache"
    ResponseCache.instance.clear
  end
  
  it "should render a basic page" do
    navigate_to "/first"
  end
  
  it "should render a deeply nested page" do
    navigate_to "/parent/child/grandchild/great-grandchild"
  end
  
  it "should respond to conditional GETs based on ETag with 304 when the page is cached" do
    navigate_to "/first"
    etag = response.headers['ETag']
    get "/first", nil, "If-None-Match" => etag
    response.headers['ETag'].should == etag
    response.response_code.should == 304
  end
  
  it "should respond to conditional GETs based on date with 304 when the page is cached" do
    navigate_to "/first"
    date = response.headers['Last-Modified']
    get "/first", nil, "If-Modified-Since" => date
    response.headers['Last-Modified'].should == date
    response.response_code.should == 304
  end
  
end
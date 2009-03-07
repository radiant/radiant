require File.dirname(__FILE__) + '/../../spec_helper'

describe Radiant::LegacyRoutes, :type => :helper do
  it "should warn about a deprecated route and pass through to the new route" do
    helper.should_receive(:warn)
    helper.should_receive(:admin_pages_url).and_return("http://test.host/admin/pages")
    helper.page_index_url.should == "http://test.host/admin/pages"
  end
  
  it "should warn about a removed route and return nil" do
    helper.should_receive(:warn)
    helper.clear_cache_url.should be_nil
  end
end
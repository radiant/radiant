require File.dirname(__FILE__) + '/../spec_helper'

describe TextileFilter do
  it "should be named Textile" do
    TextileFilter.filter_name.should == "Textile"
  end
  
  it "should filter text according to Textile rules" do
    TextileFilter.filter('h1. Test').should == '<h1>Test</h1>'
  end
end
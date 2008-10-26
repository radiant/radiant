require File.dirname(__FILE__) + "/../../spec_helper"

describe StringExtensions do
  it "should properly slugify Strings" do
    str = "I am the VERy_model   0f a m()d3rn major general"
    str.to_slug.should == "i-am-the-very_model-0f-a-md3rn-major-general"
    str.slugify.should == str.to_slug
    str.slugerize.should == str.to_slug
  end
end
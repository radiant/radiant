require File.dirname(__FILE__) + "/../../spec_helper"

describe "String extensions" do
  it "should properly slugify Strings" do
    str = "I am the VERy_model   0f a m()d3rn major general"
    expected = str.parameterize
    str.to_slug.should == expected
    str.slugify.should == expected
    str.slugerize.should == expected
  end
end
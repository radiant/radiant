require File.dirname(__FILE__) + "/../../spec_helper"

describe "String extensions" do
  it "should properly slugify Strings" do
    str = "I am the VERy_model   0f a m()d3rn major general"
    expected = str.parameterize
    expect(str.to_slug).to eq(expected)
    expect(str.slugify).to eq(expected)
    expect(str.slugerize).to eq(expected)
  end
end
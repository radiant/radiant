require File.dirname(__FILE__) + "/../../spec_helper"

describe Admin::UserHelper do
  scenario :users
  
  it "should render a string containing the user's roles" do
    roles(users(:admin)).should == "Administrator"
    roles(users(:developer)).should == "Developer"
    roles(users(:existing)).should == ''
  end
end
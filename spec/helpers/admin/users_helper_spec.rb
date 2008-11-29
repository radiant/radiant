require File.dirname(__FILE__) + "/../../spec_helper"

describe Admin::UsersHelper do
  scenario :users
  
  it "should render a string containing the user's roles" do
    helper.roles(users(:admin)).should == "Administrator"
    helper.roles(users(:developer)).should == "Developer"
    helper.roles(users(:existing)).should == ''
  end
end
require File.dirname(__FILE__) + "/../../spec_helper"

describe Admin::UsersHelper do
  dataset :users
  
  it "should render a string containing the user's roles" do
    helper.roles(users(:admin)).should == I18n.t('admin')
    helper.roles(users(:designer)).should == I18n.t('designer')
    helper.roles(users(:existing)).should == ''
  end
end
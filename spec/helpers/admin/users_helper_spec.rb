require File.dirname(__FILE__) + "/../../spec_helper"

describe Radiant::Admin::UsersHelper do
  #dataset :users

  it "should render a string containing the user's roles" do
    expect(helper.roles(users(:admin))).to eq(I18n.t('admin'))
    expect(helper.roles(users(:designer))).to eq(I18n.t('designer'))
    expect(helper.roles(users(:existing))).to eq('')
  end
end
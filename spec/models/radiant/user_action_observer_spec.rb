require File.dirname(__FILE__) + '/../../spec_helper'

describe Radiant::UserActionObserver do
  
  test_helper :user, :page, :layout
  let(:user){ User.new(user_params) }

  before(:each) do
    Radiant::UserActionObserver.current_user = user
  end
  
  it 'should observe create' do
    [
      User.create(user_params),
      Page.create(page_params),
      Layout.create(layout_params)
    ].each do |model|
      model.created_by.should == user
    end
  end

  it 'should observe update' do
    [
      User.create(user_params),
      Page.create(page_params),
      Layout.create(layout_params)
    ].each do |model|
      model.attributes = model.attributes.dup
      model.save.should == true
      model.updated_by.should == user
    end
  end
end
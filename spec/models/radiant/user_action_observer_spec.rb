require File.dirname(__FILE__) + '/../../spec_helper'

describe Radiant::UserActionObserver do
  
  test_helper :user, :page, :layout
  let(:user){ User.new(user_params) }

  before(:each) do
    Radiant::UserActionObserver.current_user = user
  end
  
  xit 'should observe create' do
    # TODO: This functionality should be moved to controller from model observer.
    [
      User.create(user_params),
      Page.create(page_params),
      Layout.create(layout_params)
    ].each do |model|
      expect(model.created_by).to eq(user)
    end
  end

  xit 'should observe update' do
    # TODO: This functionality should be moved to controller from model observer.
    [
      User.create(user_params),
      Page.create(page_params),
      Layout.create(layout_params)
    ].each do |model|
      expect(model.updated_by).to be_nil
      expect(model.save).to eq(true)
      expect(model.updated_by).to eq(user)
    end
  end
end
require 'spec_helper'

describe Radiant::AdminController do
  dataset :users

  it 'should set the current user for the UserActionObserver' do
    UserActionObserver.current_user = nil
    controller.should_receive(:current_user).and_return(users(:admin))
    controller.send :set_current_user
    UserActionObserver.current_user.should == users(:admin)
  end
end

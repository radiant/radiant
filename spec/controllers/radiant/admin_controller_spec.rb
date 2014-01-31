require 'spec_helper'

describe Radiant::AdminController do
  let(:admin){ 'admin' }

  it 'should set the current user for the UserActionObserver' do
    Radiant::UserActionObserver.current_user = nil
    controller.should_receive(:current_user).and_return(admin)
    controller.send :set_current_user
    Radiant::UserActionObserver.current_user.should == admin
  end
end

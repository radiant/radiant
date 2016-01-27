require 'spec_helper'

describe Radiant::AdminController do
  let(:admin){ 'admin' }

  it 'should set the current user for the UserActionObserver' do
    Radiant::UserActionObserver.current_user = nil
    expect(controller).to receive(:current_user).and_return(admin)
    controller.send :set_current_user
    expect(Radiant::UserActionObserver.current_user).to eq(admin)
  end
end

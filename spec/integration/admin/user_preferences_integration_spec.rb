require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe 'User preferences' do
  scenario :users
  
  before do
    login :existing
  end
  
  it 'should editable by owner' do
    navigate_to '/admin/preferences/edit'
    submit_form :user => {:password => 'me new one', :password_confirmation => 'me new one', :email => 'mine@example.com'}
    response.body.should have_tag('#notice')
    response.should be_showing('/admin/pages')
    
    current_user.reload.email.should == 'mine@example.com'
    current_user.should be_authenticated('me new one')
  end
end
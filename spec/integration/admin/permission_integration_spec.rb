require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe 'User permissions' do
  dataset :users
  
  it 'should allow administrators to login' do
    navigate_to '/admin/login'
    submit_form :user => {:login => 'admin', :password => 'password'}
    response.should be_showing('/admin/pages')
  end
  
  it 'should allow developers to login' do
    navigate_to '/admin/login'
    submit_form :user => {:login => 'developer', :password => 'password'}
    response.should be_showing('/admin/pages')
  end
  
  it 'should allow users to login' do
    navigate_to '/admin/login'
    submit_form :user => {:login => 'existing', :password => 'password'}
    response.should be_showing('/admin/pages')
  end
  
end
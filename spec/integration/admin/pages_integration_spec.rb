require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe 'Pages' do
  scenario :users
  
  before do
    login :admin
  end
  
  it 'should be able to go to pages tab' do
    click_on :link => '/admin/pages'
  end
  
  it 'should be able to create the home page' do
    navigate_to '/admin/pages/new/homepage'
    submit_form 'new_page', :continue => 'Save and Continue', :page => {:title => 'My Site', :parts => [{:name => 'body', :content => 'Under Construction'}], :status_id => Status[:published]}
    response.should_not have_tag('#error')
    response.body.should have_text('Under Construction')
    response.body.should have_text('My Site')
    
    navigate_to '/'
    response.body.should have_text('Under Construction')
    response.body.should have_text('My Site')
  end
end
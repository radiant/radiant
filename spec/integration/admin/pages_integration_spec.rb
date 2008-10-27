require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe 'Pages' do
  scenario :users
  
  before do
    Radiant::Config['defaults.page.parts'] = 'body'
    Page.delete_all
    login :admin
  end
  
  it 'should be able to go to pages tab' do
    click_on :link => '/admin/pages'
  end
  
  it 'should be able to create the home page' do
    navigate_to '/admin/pages/new'
    submit_form 'new_page', :continue => 'Save and Continue', :page => {:title => 'My Site', :slug => '/', :breadcrumb => 'My Site', :parts => [{:name => 'body', :content => 'Under Construction'}], :status_id => Status[:published].id}
    response.should_not have_tag('#error')
    response.should have_text(/Under\sConstruction/)
    response.should have_text(/My Site/)
    
    navigate_to '/'
    response.should have_text(/Under Construction/)
  end
end
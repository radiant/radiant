require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe 'Page management' do
  dataset :users
  
  def have_slug(expected)
    satisfy do |response|
      response.should have_tag('#page_slug') do |tags|
        tags.size.should == 1
        tags.first['value'].should == (expected.blank? ? nil : expected)
      end
      true
    end
  end
  
  before do
    Radiant::Config['defaults.page.parts'] = 'body'
    login :admin
  end
  
  it 'should list pages' do
    click_on :link => '/admin/pages'
  end
  
  it 'should allow the user to create the homepage' do
    navigate_to '/admin/pages/new'
    response.should have_slug('/')
    submit_form 'new_page', :continue => 'Save and Continue', :page => {:title => 'My Site', :slug => '/', :breadcrumb => 'My Site', :parts => [{:name => 'body', :content => 'Under Construction'}], :status_id => Status[:published].id}
    response.should_not have_tag('#error')
    response.should have_text(/Under\sConstruction/)
    response.should have_text(/My Site/)
    
    navigate_to '/'
    response.should have_text(/Under Construction/)
  end
  
  describe 'with homepage' do
    dataset :home_page
    
    it 'should allow the user to create child pages' do
      navigate_to "/admin/pages/#{page_id(:home)}/children/new"
      response.should have_slug('')
      
      lambda do
        submit_form 'new_page', :continue => 'Save and Continue', :page => {
          :title => 'My Child', :status_id => Status[:published].id,
          :slug => 'my-child', :breadcrumb => 'My Child',
          :parts => [{:name => 'body', :content => 'Under Construction'}]
        }
      end.should change(Page, :count).by(1)
      
      navigate_to '/my-child'
      response.should have_text(/Under Construction/)
    end
    
    it 'should show errors creating pages' do
      navigate_to "/admin/pages/#{page_id(:home)}/children/new"
      lambda do
        submit_form 'new_page', :continue => 'Save and Continue', :page => {}
      end.should_not change(Page, :count)
      response.should render_form_errors(
        :page => {:title => /required/, :slug => /required/, :breadcrumb => /required/}
      )
    end
    
    it 'should allow the user to delete the home page' do
      id = page_id(:home)
      navigate_to "/admin/pages/#{id}/remove"
      response.should have_text(/permanently remove/)
      submit_form 'form.edit_page' 
      response.should be_showing('/admin/pages')
    end
  end
end

describe "Pages as resource" do
  dataset :pages, :users
  
  it "should require authentication" do
    get "/admin/pages.xml"
    response.headers.keys.should include('WWW-Authenticate')
  end
  
  it 'should reject invalid creds' do
    get "/admin/pages.xml", nil, :authorization => encode_credentials(%w(admin badpassword))
    response.headers.keys.should include('WWW-Authenticate')
  end
  
  it 'should be obtainable by users' do
    get "/admin/pages.xml", nil, :authorization => encode_credentials(%w(admin password))
    response.body.should match(/xml/)
  end
  
  it 'should be obtainable as list' do
    get "/admin/pages.xml", nil, :authorization => encode_credentials(%w(admin password))
    response.body.should match(/pages/)
  end
  
  it "should include parts" do
    get "/admin/pages/#{page_id(:first)}.xml", nil, :authorization => encode_credentials(%w(admin password))
    response.body.should match(/parts type="array"/)
  end
end
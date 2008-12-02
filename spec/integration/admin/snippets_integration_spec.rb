require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe 'Snippets' do
  scenario :users, :snippets
  
  before do
    login :admin
  end
  
  it 'should be able to go to snippets tab' do
    click_on :link => '/admin/snippets'
  end
  
  it 'should be able to create a new snippet' do
    navigate_to '/admin/snippets/new'
    lambda do
      submit_form :snippet => {:name => 'Mine', :content => 'Me Snippet'}
    end.should change(Snippet, :count).by(1)
  end
  
  it "should display form errors" do
    navigate_to '/admin/snippets/new'
    lambda do
      submit_form :snippet => {:content => 'Me snippet'}
    end.should_not change(Snippet, :count)
    response.should have_tag("#error")
  end

  it "should redisplay the edit screen on 'Save & Continue Editing'" do
    navigate_to '/admin/snippets/new'
    submit_form :snippet => {:name => 'Mine', :content => 'Me Snippet'}, :continue => "Save and Continue"
    response.should have_tag('form')
    response.should have_tag('#notice')
    response.should have_text(/Me Snippet/)
  end
end

describe 'Snippet as resource' do
  scenario :users
  
  before do
    @snippet = Snippet.create!(:name => 'Snippet', :content => 'Content')
  end
  
  it 'should require authentication' do
    get "/admin/snippets/#{@snippet.id}.xml"
    response.headers.keys.should include('WWW-Authenticate')
  end
  
  it 'should reject invalid creds' do
    get "/admin/snippets/#{@snippet.id}.xml", nil, :authorization => encode_credentials(%w(admin badpassword))
    response.headers.keys.should include('WWW-Authenticate')
  end
  
  it 'should be obtainable by users' do
    get "/admin/snippets/#{@snippet.id}.xml", nil, :authorization => encode_credentials(%w(admin password))
    response.body.should match(/xml/)
  end
  
  it 'should be obtainable as list' do
    get "/admin/snippets.xml", nil, :authorization => encode_credentials(%w(admin password))
    response.body.should match(/snippets/)
  end
end
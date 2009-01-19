require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "Internet Explorer specific tests" do
  dataset :pages, :users
  
  before do
    Radiant::Config['defaults.page.parts'] = 'body'
    login :admin
  end
  
  it 'should allow Internet Explorer to navigate to the pages when logged in' do
    get '/admin/pages', nil, :accept => "image/gif, image/x-xbitmap, image/jpeg, image/pjpeg, application/x-ms-application, application/vnd.ms-xpsdocument, application/xaml+xml, application/x-ms-xbap, application/x-shockwave-flash, application/vnd.ms-excel, application/vnd.ms-powerpoint, application/msword, */*"
    #TODO: fix respone should to actually match the expectation
    response.should_not have_text(/Missing\ template/)
  end
end
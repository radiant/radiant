require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "Proper content negotiation" do
  dataset :pages, :users
  
  before do
    Radiant::Config['defaults.page.parts'] = 'body'
    login :admin
  end
  
  it 'should use a default html format and navigate to the pages when logged in' do
    get '/admin/pages', nil, :accept => "image/gif, image/x-xbitmap, image/jpeg, image/pjpeg, application/x-ms-application, application/vnd.ms-xpsdocument, application/xaml+xml, application/x-ms-xbap, application/x-shockwave-flash, application/vnd.ms-excel, application/vnd.ms-powerpoint, application/msword, */*"
    response.should be_showing("/admin/pages")
    response.should_not have_text(/Missing\ template/)
  end
  
  it "should allow the user agent to request a different format via the extension" do
    get '/admin/pages.xml', nil, :accept => "image/gif, image/x-xbitmap, image/jpeg, image/pjpeg, application/x-ms-application, application/vnd.ms-xpsdocument, application/xaml+xml, application/x-ms-xbap, application/x-shockwave-flash, application/vnd.ms-excel, application/vnd.ms-powerpoint, application/msword, */*"
    response.should have_text(/<\?xml/)
  end
  
  it "should not render html format when requesting via Ajax" do
    get "/admin/pages/#{page_id(:home)}/children", {'level' => 0}, "X-Requested-With" => "XMLHttpRequest", :accept => "text/javascript, text/html, application/xml, text/xml, */*"
    response.should_not have_text(/Radiant CMS/)
    response.should have_tag("tr[id$=#{page_id(:another)}]")
  end
end
require File.dirname(__FILE__) + '/../spec_helper'

describe SiteController do
  dataset :pages

  it "should find and render home page" do
    get :show_page, :url => ''
    response.should be_success
    response.body.should == 'Hello world!'
  end

  it "should find a page one level deep" do
    get :show_page, :url => 'first/'
    response.should be_success
    response.body.should == 'First body.'
  end

  it "should find a page two levels deep" do
    get :show_page, :url => 'parent/child/'
    response.should be_success
    response.body.should == 'Child body.'
  end

  it "should show page not found" do
    get :show_page, :url => 'a/non-existant/page'
    response.response_code.should == 404
    response.should render_template('site/not_found')
  end

  it "should redirect to admin if missing root" do
    Page.should_receive(:find_by_url).and_raise(Page::MissingRootPageError)
    get :show_page, :url => '/'
    response.should redirect_to(welcome_url)
  end

  it "should parse pages with Radius" do
    get :show_page, :url => 'radius'
    response.should be_success
    response.body.should == 'Radius body.'
  end

  it "should render 404 if page is not published status" do
    ['draft', 'hidden'].each do |url|
      get :show_page, :url => url
      response.should be_missing
      response.should render_template('site/not_found')
    end
  end

  it "should display draft and hidden pages on default dev site" do
    request.host = "dev.site.com"
    ['draft', 'hidden'].each do |url|
      get :show_page, :url => url
      response.should be_success
    end
  end

  it "should display draft and hidden pages on dev site in config" do
    controller.config = { 'dev.host' => 'mysite.com' }
    request.host = 'mysite.com'
    ['draft', 'hidden'].each do |url|
      get :show_page, :url => url
      response.should be_success
    end
  end

  it "should not display draft and hidden pages on default dev site when dev.host specified" do
    controller.config = { 'dev.host' => 'mysite.com' }
    request.host = 'dev.mysite.com'
    ['draft', 'hidden'].each do |url|
      get :show_page, :url => url
      response.should be_missing
    end
  end
  
  it "should not require login" do
    lambda { get :show_page, :url => '/' }.should_not require_login
  end

  describe "scheduling" do    
    before do 
      @sched_page = Page.find(103)
    end    
    it "should not display scheduled pages on live site" do
      @sched_page.published_at = Time.now + 5000
      @sched_page.save
      request.host = 'mysite.com'      
      get :show_page, :url => @sched_page.slug
      response.response_code.should == 404
      response.should render_template('site/not_found')
    end
    
    it "should update status of scheduled pages on home page" do
      @sched_page.published_at = Time.now - 50000
      @sched_page.status_id = 90

      get :show_page, :url => '/'
      response.body.should == 'Hello world!'
      
      @sched_page2 = Page.find(103)
      @sched_page2.status_id.should == 100
    end
    
  end


  describe "caching" do
    it "should add a default Cache-Control header with public and max-age of 5 minutes" do
      get :show_page, :url => ''
      response.headers['Cache-Control'].should =~ /public/
      response.headers['Cache-Control'].should =~ /max-age=300/
    end
    
    it "should pass along the etag set by the page" do
      get :show_page, :url => '/'
      response.headers['ETag'].should be
    end
    
    %w{put post delete}.each do |method|
      it "should prevent upstream caching on #{method.upcase} requests" do
        send(method, :show_page, :url => '/')
        response.headers['Cache-Control'].should =~ /private/
        response.headers['Cache-Control'].should =~ /no-cache/
        response.headers['ETag'].should be_blank
      end
    end
    
    it "should return a not-modified response when the sent etag matches" do
      response.stub!(:etag).and_return("foobar")
      request.if_none_match = 'foobar'
      get :show_page, :url => '/'
      response.response_code.should == 304
      response.body.should be_blank
    end
    
    it "should prevent upstream caching when the page should not be cached" do
      @page = pages(:home)
      Page.should_receive(:find_by_url).and_return(@page)
      @page.should_receive(:cache?).and_return(false)
      get :show_page, :url => '/'
      response.headers['Cache-Control'].should =~ /private/
      response.headers['Cache-Control'].should =~ /no-cache/
      response.headers['ETag'].should be_blank
    end
    
    it "should prevent upstream caching in dev mode" do
      request.host = "dev.site.com"
      
      get :show_page, :url => '/'
      response.headers['Cache-Control'].should =~ /private/
      response.headers['Cache-Control'].should =~ /no-cache/
      response.headers['ETag'].should be_blank
    end
    
    it "should set the default cache timeout (max-age) to a value assigned by the user" do
      SiteController.cache_timeout = 10.minutes
      get :show_page, :url => '/'
      response.headers['Cache-Control'].should =~ /public/
      response.headers['Cache-Control'].should =~ /max-age=600/
    end
  end
end
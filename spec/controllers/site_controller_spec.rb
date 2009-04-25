require File.dirname(__FILE__) + '/../spec_helper'

describe SiteController, "routes page requests" do
  dataset :pages

  before(:each) do
    # don't bork results with stale cache items
    controller.cache.clear
  end

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
end
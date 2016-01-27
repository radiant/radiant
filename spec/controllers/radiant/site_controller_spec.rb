require File.dirname(__FILE__) + '/../../spec_helper'

describe Radiant::SiteController do
  routes { Radiant::Engine.routes }
  #dataset :pages

  it "should find and render home page" do
    get :show_page, url: ''
    expect(response).to be_success
    expect(response.body).to eq('Hello world!')
  end

  it "should find a page one level deep" do
    get :show_page, url: 'first/'
    expect(response).to be_success
    expect(response.body).to eq('First body.')
  end

  it "should find a page two levels deep" do
    get :show_page, url: 'parent/child/'
    expect(response).to be_success
    expect(response.body).to eq('Child body.')
  end

  it "should show page not found" do
    get :show_page, url: 'a/non-existant/page'
    expect(response.response_code).to eq(404)
    expect(response).to render_template('site/not_found')
  end

  it "should redirect to admin if missing root" do
    expect(Page).to receive(:find_by_path).and_raise(Page::MissingRootPageError)
    get :show_page, url: '/'
    expect(response).to redirect_to(welcome_url)
  end

  it "should pass pagination parameters to the page" do
    page = pages(:first)
    param_name = WillPaginate::ViewHelpers.pagination_options[:param_name] || :p
    pagination_parameters = {param_name => 3, per_page: 100}
    allow(controller).to receive(:pagination_parameters).and_return(pagination_parameters)
    allow(controller).to receive(:find_page).and_return(page)

    get :show_page, url: 'first/'

    expect(page.pagination_parameters).to eq(pagination_parameters)
  end

  it "should parse pages with Radius" do
    get :show_page, url: 'radius'
    expect(response).to be_success
    expect(response.body).to eq('Radius body.')
  end

  it "should render 404 if page is not published status" do
    ['draft', 'hidden'].each do |url|
      get :show_page, url: url
      expect(response).to be_missing
      expect(response).to render_template('site/not_found')
    end
  end

  it "should display draft and hidden pages on default dev site" do
    request.host = "dev.site.com"
    ['draft', 'hidden'].each do |url|
      get :show_page, url: url
      expect(response).to be_success
    end
  end

  it "should display draft and hidden pages on dev site in config" do
    controller.config = { 'dev.host' => 'mysite.com' }
    request.host = 'mysite.com'
    ['draft', 'hidden'].each do |url|
      get :show_page, url: url
      expect(response).to be_success
    end
  end

  ['draft','hidden'].each do |type|
    it "it should display #{type} pages on default dev site when dev.host specified" do
      controller.config = { 'dev.host' => 'mysite.com' }
      request.host = 'dev.mysite.com'
      get :show_page, url: type
      expect(response).not_to be_missing
    end
  end

  it "should not require login" do
    expect { get :show_page, url: '/' }.not_to require_login
  end

  describe "scheduling" do
    before do
      @sched_page = Page.find_by_title('d')
    end
    it "should not display scheduled pages on live site" do
      @sched_page.published_at = Time.now + 5000
      @sched_page.save
      request.host = 'mysite.com'
      get :show_page, url: @sched_page.slug
      expect(response.response_code).to eq(404)
      expect(response).to render_template('site/not_found')
    end

    it "should update status of scheduled pages on home page" do
      @sched_page.published_at = Time.now - 50000
      @sched_page.status_id = 90

      get :show_page, url: '/'
      expect(response.body).to eq('Hello world!')

      @sched_page2 = Page.find_by_title('d')
      expect(@sched_page2.status_id).to eq(100)
    end

  end

  describe "caching" do
    it "should add a default Cache-Control header with public and max-age of 5 minutes" do
      get :show_page, url: '/'
      expect(response.headers['Cache-Control']).to match(/public/)
      expect(response.headers['Cache-Control']).to match(/max-age=300/)
    end

    it "should pass along the etag set by the page" do
      get :show_page, url: '/'
      expect(response.headers['ETag']).to be
    end

    %w{put post delete}.each do |method|
      it "should prevent upstream caching on #{method.upcase} requests" do
        send(method, :show_page, url: '/')
        expect(response.headers['Cache-Control']).to match(/private/)
        expect(response.headers['Cache-Control']).to match(/no-cache/)
        expect(response.headers['ETag']).to be_blank
      end
    end

    it "should return a not-modified response when the sent etag matches" do
      allow(response).to receive(:etag).and_return("foobar")
      request.if_none_match = 'foobar'
      get :show_page, url: '/'
      expect(response.response_code).to eq(304)
      expect(response.body).to be_blank
    end

    it "should prevent upstream caching when the page should not be cached" do
      @page = pages(:home)
      expect(Page).to receive(:find_by_path).and_return(@page)
      expect(@page).to receive(:cache?).and_return(false)
      get :show_page, url: '/'
      expect(response.headers['Cache-Control']).to match(/private/)
      expect(response.headers['Cache-Control']).to match(/no-cache/)
      expect(response.headers['ETag']).to be_blank
    end

    it "should prevent upstream caching in dev mode" do
      request.host = "dev.site.com"

      get :show_page, url: '/'
      expect(response.headers['Cache-Control']).to match(/private/)
      expect(response.headers['Cache-Control']).to match(/no-cache/)
      expect(response.headers['ETag']).to be_blank
    end

    it "should set the default cache timeout (max-age) to a value assigned by the user" do
      SiteController.cache_timeout = 10.minutes
      get :show_page, url: '/'
      expect(response.headers['Cache-Control']).to match(/public/)
      expect(response.headers['Cache-Control']).to match(/max-age=600/)
    end
  end

  describe "pagination" do
    it "should pass through pagination parameters to the page" do
      @page = pages(:home)
      allow(Page).to receive(:find_by_path).and_return(@page)
      expect(@page).to receive(:pagination_parameters=).with({page: '3', per_page: '12'})
      get :show_page, url: '/', page: '3', per_page: '12'
    end
  end
end

require File.dirname(__FILE__) + '/../../spec_helper'

describe Admin::PagesController do
  dataset :users, :pages

  before :each do
    login_as :existing
  end

  it "should route children to the pages controller" do
    route_for(:controller => "admin/pages", :page_id => '1', 
      :action => "index").should == '/admin/pages/1/children'
    route_for(:controller => "admin/pages", :page_id => '1', 
      :action => 'new').should == '/admin/pages/1/children/new'
  end

  it "should setup the response cache when it initializes" do
    @controller.cache.should be_kind_of(ResponseCache)
  end
  
  describe "viewing the sitemap" do
    integrate_views

    it "should render when the homepage is present" do
      get :index
      response.should be_success
      assigns(:homepage).should be_kind_of(Page)
      response.should render_template('index')
    end

    it "should allow the index to render even with there are no pages" do
      Page.destroy_all
      get :index
      response.should be_success
      assigns(:homepage).should be_nil
      response.should render_template('index')
    end

    it "should show the tree partially expanded by default" do
      get :index
      response.should be_success
      assert_rendered_nodes_where { |page| [nil, page_id(:home)].include?(page.parent_id) }
    end

    it "should show the tree partially expanded even when the expanded_rows cookie is empty" do
      write_cookie('expanded_rows', '')
      get :index
      response.should be_success
      cookies['expanded_rows'].should be_nil
      assert_rendered_nodes_where { |page| [nil, page_id(:home)].include?(page.parent_id) }
    end

    it "should show the tree partially expanded according to the expanded_rows cookie" do
      cookie = "#{page_id(:home)},#{page_id(:parent)},#{page_id(:child)}"
      write_cookie('expanded_rows', cookie)
      get :index
      response.should be_success
      assert_rendered_nodes_where { |page| [nil, page_id(:home), page_id(:parent), page_id(:child)].include?(page.parent_id) }
    end

    it "should show the tree with a mangled cookie" do
      cookie = "#{page_id(:home)},#{page_id(:parent)},:#*)&},9a,,,"
      write_cookie('expanded_rows', cookie)
      get :index
      response.should be_success
      assert_rendered_nodes_where { |page| [nil, page_id(:home), page_id(:parent)].include?(page.parent_id) }
      assigns(:homepage).should_not be_nil
    end
    
    it "should render the appropriate children when branch of the site map is expanded via AJAX" do
      xml_http_request :get, :index, :page_id => page_id(:home), :level => '1'
      response.should be_success
      assigns(:level).should == 1
      response.body.should_not have_text('<head>')
      response.content_type.should == 'text/html'
      response.charset.should == 'utf-8'
    end
  end
  
  describe "permissions" do
    
    [:admin, :developer, :non_admin, :existing].each do |user|
      {
        :post => :create,
        :put => :update,
        :delete => :destroy
      }.each do |method, action|
        it "should require login to access the #{action} action" do
          logout
          send method, action, :id => Page.first.id
          response.should redirect_to('/admin/login')
        end
        
        it "should allow access to #{user.to_s.humanize}s for the #{action} action" do
          login_as user
          send method, action, :id => Page.first.id
          response.should redirect_to('/admin/pages')
        end
      end
    end
    
    [:index, :show, :new, :edit, :remove].each do |action|
      before :each do
        @parameters = lambda do 
          case action
          when :index
            {}
          when :new
            {:page_id => page_id(:home)}
          else
            {:id => Page.first.id} 
          end
        end
      end
      
      it "should require login to access the #{action} action" do
        logout
        lambda { send(:get, action, @parameters.call) }.should require_login
      end

      it "should allow access to admins for the #{action} action" do
        lambda { 
          send(:get, action, @parameters.call) 
        }.should restrict_access(:allow => [users(:admin)], 
                                 :url => '/admin/pages')
      end

      it "should allow access to developers for the #{action} action" do
        lambda { 
          send(:get, action, @parameters.call) 
        }.should restrict_access(:allow => [users(:developer)], 
                                 :url => '/admin/pages')
      end
    
      it "should allow non-developers and non-admins for the #{action} action" do
        lambda { 
          send(:get, action, @parameters.call) 
        }.should restrict_access(:allow => [users(:non_admin), users(:existing)],
                                 :url => '/admin/pages')
      end
    end
  end
  
  
  describe "prompting page removal" do
    integrate_views
    
    # TODO: This should be in a view or integration spec
    it "should render the expanded descendants of the page being removed" do
      get :remove, :id => page_id(:parent), :format => 'html' # shouldn't need this!
      rendered_pages = [:parent, :child, :grandchild, :great_grandchild, :child_2, :child_3].map {|p| pages(p) }
      rendered_pages.each do |page|
        response.should have_tag("tr#page-#{page.id}")
      end
    end
  end
  
  it "should initialize meta and buttons_partials in new action" do
    get :new, :page_id => page_id(:home)
    response.should be_success
    assigns(:meta).should be_kind_of(Array)
    assigns(:buttons_partials).should be_kind_of(Array)
  end

  it "should initialize meta and buttons_partials in edit action" do
    get :edit, :id => page_id(:home)
    response.should be_success
    assigns(:meta).should be_kind_of(Array)
    assigns(:buttons_partials).should be_kind_of(Array)
  end
  
  protected

    def assert_rendered_nodes_where(&block)
      wanted, unwanted = Page.find(:all).partition(&block)
      wanted.each do |page|
        response.should have_tag("tr#page-#{page.id}")
      end
      unwanted.each do |page|
        response.should_not have_tag("tr#page-#{page.id}")
      end
    end

    def write_cookie(name, value)
      request.cookies[name] = CGI::Cookie.new(name, value)
    end
end

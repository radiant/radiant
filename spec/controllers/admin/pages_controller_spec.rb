require File.dirname(__FILE__) + '/../../spec_helper'

describe Admin::PagesController do
  scenario :users, :pages
  test_helper :pages, :page_parts, :caching

  integrate_views

  before :each do
    login_as :existing
  end

  it "should setup the response cache when it initializes" do
    @controller.cache.should be_kind_of(ResponseCache)
  end

  it "should allow you to view the index" do
    get :index
    response.should be_success
    assigns(:homepage).should be_kind_of(Page)
  end

  it "should allow the index to render even with there are no pages" do
    Page.destroy_all
    get :index
    response.should be_success
    assigns(:homepage).should be_nil
  end

  it "should show the tree partialy expanded on the index" do
    get :index
    response.should be_success
    assert_rendered_nodes_where { |page| [nil, page_id(:home)].include?(page.parent_id) }
  end

  it "should show the tree partialy expanded on the index even when the expanded_rows cookie is empty" do
    write_cookie('expanded_rows', '')
    get :index
    response.should be_success
    cookies['expanded_rows'].should be_nil
    assert_rendered_nodes_where { |page| [nil, page_id(:home)].include?(page.parent_id) }
  end

  it "should show the tree partially expanded on the index according to the expanded_rows cookie" do
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

  it "should allow you to enter information for a new page" do
    @controller.config = {
      'defaults.page.parts' => 'body, extended, summary',
      'defaults.page.status' => 'published'
    }

    get :new, :parent_id => page_id(:home), :page => page_params
    response.should be_success
    response.should render_template('admin/page/edit')

    page = assigns(:page)
    page.should be_kind_of(Page)
    page.title.should be_nil
    page.parent.should == pages(:home)
    page.parts.size.should == 3
    page.status.should == Status[:published]
  end

  it "should allow you to enter information for a new page and set the slug and breadcrumb" do
    get :new, :parent_id => page_id(:home), :page => page_params, :slug => 'test', :breadcrumb => 'me'
    response.should be_success

    page = assigns(:page)
    page.slug.should == 'test'
    page.breadcrumb.should == 'me'
  end

  it "should allow you to create a new page" do
    @cache = @controller.cache = FakeResponseCache.new
    post :new, :parent_id => page_id(:home), :page => page_params(:title => "New Page")
    response.should redirect_to(page_index_url)
    flash[:notice].should match(/saved/)

    page = assigns(:page)
    page.parts.size.should == 0

    Page.find_by_title("New Page").should_not be_nil
    @cache.should be_cleared
  end

  it "should show errors when you try and create a new page with invalid data" do
    post :new, :parent_id => page_id(:home), :page => page_params(:title => "New Page", :status_id => 'abc')
    response.should be_success
    flash[:error].should match(/error/)
    Page.find_by_title("New Page").should be_nil
  end

  it "should allow you to create a new page with page parts" do
    post(:new, :parent_id => page_id(:home), :page => page_params(:title => "New Page"),
      :part => {
        '1' => part_params(:name => 'test-part-1'),
        '2' => part_params(:name => 'test-part-2')
      }
    )
    response.should redirect_to(page_index_url)

    page = Page.find_by_title("New Page")
    page.should_not be_nil

    names = page.parts.collect { |part| part.name }.sort
    names.should == ['test-part-1', 'test-part-2']
  end

  it "should not allow you to create a new page with an invalid part" do
    @part_name = 'extra long ' * 25
    post :new, :parent_id => page_id(:home), :page => page_params(:title => "New Page"), :part => { '1' => part_params(:name => @part_name)}
    response.should be_success # not redirected
    flash[:error].should match(/error/)
    Page.find_by_title("New Page").should be_nil
    PagePart.find_by_name(@part_name).should be_nil
  end

  it "should allow you to save and continue editing" do
    post :new, :parent_id => page_id(:home), :page => page_params(:title => "New Page"), :continue => 'Save and Continue Editing'
    page = Page.find_by_title("New Page")
    response.should redirect_to(page_edit_url(:id => page.id))
  end

  it "should initialize meta and buttons_partials in new action" do
    get :new, :parent_id => page_id(:home)
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

  it "should allow you to edit a page" do
    get :edit, :id => page_id(:home), :page => page_params
    response.should be_success

    page = assigns(:page)
    page.should be_kind_of(Page)
    page.title.should == 'Home'
  end

  it "should allow you to save changes to a page" do
    @cache = @controller.cache = FakeResponseCache.new
    post :edit, :id => page_id(:home), :page => { :title => "Updated Home Page" }
    response.should be_redirect
    page = pages(:home)
    page.title.should == "Updated Home Page"
    @cache.should be_cleared
  end

  it "should re-render the form when the page fails to save" do
    @cache = controller.cache = FakeResponseCache.new
    post :edit, :id => page_id(:home), :page => { :slug => '' }
    response.should render_template("edit")
    assigns[:page].should == pages(:home)
  end

  it "should allow you to save changes to a page and its parts" do
    create_page("New Page") do
      create_page_part('test-part-1')
      create_page_part('test-part-2')
    end
    page = pages(:new_page)
    page.parts.size.should == 2

    post :edit, :id => page.id, :page => {}, :part => {'1' => part_params(:name => 'test-part-1', :content => 'changed')}
    response.should be_redirect

    page = pages(:new_page)
    page.parts.size.should == 1
    page.parts.first.content.should == 'changed'
  end

  it "should allow you to edit pages with optimistic locking" do
    create_page("New Page")
    post :edit, :id => page_id(:new_page), :page => page_params(:status_id => '1', :lock_version => '12')
    response.should be_success # not redirected
    flash[:error].should match(/has been modified/)
  end

  it "should allow you to edit pages and parts with optimistic locking" do
    create_page("New Page") do
      create_page_part('test-part-1', :content => 'original-1')
    end

    post :edit, :id => page_id(:new_page), :page => page_params(:status_id => '1', :lock_version => '12'), :part => {'1' => part_params(:name => 'test-part-1', :content => 'changed-1')}
    response.should be_success # not redirected
    flash[:error].should match(/has been modified/)

    # changed value must not be saved
    page_parts(:test_part_1).content.should == 'original-1'

    # but must be rendered to page
    response.should have_tag('textarea', 'changed-1')
  end
  
  it "should prompt you when deleting a page" do
    page = pages(:first)
    get :remove, :id => page.id
    response.should be_success
    assigns(:page).should == page
    Page.find(page.id).should_not be_nil
  end

  it "should show all children when prompting you during deletion regardless of sitemap expansion" do
    page = pages(:home)
    get :remove, :id => page.id
    response.should be_success
    Page.find(:all).each do |page|
      @response.should have_tag("tr#page-#{page.id}")
    end
  end

  it "should allow you to delete a page" do
    page = pages(:first)
    post :remove, :id => page.id
    response.should redirect_to(page_index_url)
    flash[:notice].should match(/removed/)
    Page.find_by_id(page.id).should be_nil
  end

  it "should use the _part template when adding a part with AJAX" do
    xml_http_request :get, :add_part
    response.should be_success
    response.should render_template('admin/page/_part')
  end

  it "should render the appropriate children when branch of the site map is expanded via AJAX" do
    xml_http_request :get, :children, :id => page_id(:home), :level => '1'
    response.should be_success
    assigns(:parent).should == pages(:home)
    assigns(:level).should == 1
    response.body.should_not have_text('<head>')
    response.content_type.should == 'text/html'
    response.charset.should == 'utf-8'
  end

  it "should render the appropriate tag reference when requested via AJAX" do
    xml_http_request :get, :tag_reference, :class_name => "Page"
    response.should be_success
    assigns(:class_name).should == "Page"
    response.should render_template("tag_reference")
  end

  it "should render the appropriate filter reference when requested via AJAX" do
    xml_http_request :get, :filter_reference, :filter_name => "Textile"
    response.should be_success
    assigns(:filter_name).should == "Textile"
    response.should render_template("filter_reference")
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

#encoding: utf-8

require File.dirname(__FILE__) + '/../../spec_helper'

describe Radiant::Admin::PagesController do
  routes { Radiant::Engine.routes }
  #dataset :users, :pages

  before :each do
    login_as :existing
  end

  it "should route children to the pages controller" do
    expect(route_for(controller: "admin/pages", page_id: '1',
      action: "index")).to eq('/admin/pages/1/children')
    expect(route_for(controller: "admin/pages", page_id: '1',
      action: 'new')).to eq('/admin/pages/1/children/new')
  end

  describe "show" do
    it "should redirect to the edit action" do
      get :show, id: 1
      expect(response).to redirect_to(edit_admin_page_path(params[:id]))
    end

    it "should show json when format is json" do
      page = Page.first
      get :show, id: page.id, format: "json"
      expect(response.body).to eq(page.to_json)
    end
  end

  describe "with invalid page id" do
    [:edit, :remove].each do |action|
      before do
        @parameters = {id: 999}
      end
      it "should redirect the #{action} action to the index action" do
        get action, @parameters
        expect(response).to redirect_to(admin_pages_path)
      end
      it "should say that the 'Page could not be found.' after the #{action} action" do
        get action, @parameters
        expect(flash[:notice]).to eq('Page could not be found.')
      end
    end
    it 'should redirect the update action to the index action' do
      put :update, @parameters
      expect(response).to redirect_to(admin_pages_path)
    end
    it "should say that the 'Page could not be found.' after the update action" do
      put :update, @parameters
      expect(flash[:notice]).to eq('Page could not be found.')
    end
    it 'should redirect the destroy action to the index action' do
      delete :destroy, @parameters
      expect(response).to redirect_to(admin_pages_path)
    end
    it "should say that the 'Page could not be found.' after the destroy action" do
      delete :destroy, @parameters
      expect(flash[:notice]).to eq('Page could not be found.')
    end
  end

  describe "viewing the sitemap" do


    it "should render when the homepage is present" do
      get :index
      expect(response).to be_success
      expect(assigns(:homepage)).to be_kind_of(Page)
      expect(response).to render_template('index')
    end

    it "should allow the index to render even with there are no pages" do
      Page.delete_all; PagePart.delete_all
      get :index
      expect(response).to be_success
      expect(assigns(:homepage)).to be_nil
      expect(response).to render_template('index')
    end

    it "should show the tree partially expanded by default" do
      get :index
      expect(response).to be_success
      assert_rendered_nodes_where { |page| [nil, page_id(:home)].include?(page.parent_id) }
    end

    it "should show the tree partially expanded even when the expanded_rows cookie is empty" do
      write_cookie('expanded_rows', '')
      get :index
      expect(response).to be_success
      expect(cookies['expanded_rows']).to be_nil
      assert_rendered_nodes_where { |page| [nil, page_id(:home)].include?(page.parent_id) }
    end

    it "should show the tree partially expanded according to the expanded_rows cookie" do
      cookie = "#{page_id(:home)},#{page_id(:parent)},#{page_id(:child)}"
      write_cookie('expanded_rows', cookie)
      get :index
      expect(response).to be_success
      assert_rendered_nodes_where { |page| [nil, page_id(:home), page_id(:parent), page_id(:child)].include?(page.parent_id) }
    end

    it "should show the tree with a mangled cookie" do
      cookie = "#{page_id(:home)},#{page_id(:parent)},:#*)&},9a,,,"
      write_cookie('expanded_rows', cookie)
      get :index
      expect(response).to be_success
      assert_rendered_nodes_where { |page| [nil, page_id(:home), page_id(:parent)].include?(page.parent_id) }
      expect(assigns(:homepage)).not_to be_nil
    end

    it "should render the appropriate children when branch of the site map is expanded via AJAX" do
      xml_http_request :get, :index, page_id: page_id(:home), level: '1'
      expect(response).to be_success
      expect(assigns(:level)).to eq(1)
      expect(response.body).not_to have_text('<head>')
      expect(response.content_type).to eq('text/html')
      expect(response.charset).to eq('utf-8')
    end
  end

  describe "permissions" do

    [:admin, :designer, :non_admin, :existing].each do |user|
      {
        post: :create,
        put: :update,
        delete: :destroy
      }.each do |method, action|
        it "should require login to access the #{action} action" do
          logout
          send method, action, id: page_id(:home)
          expect(response).to redirect_to('/admin/login')
        end

        it "should allow access to #{user.to_s.humanize}s for the #{action} action" do
          login_as user
          expect(controller).to receive(:paginated?).and_return(false)
          send method, action, id: page_id(:home)
          expect(response).to redirect_to('http://test.host/admin/pages')
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
            {page_id: page_id(:home)}
          else
            {id: page_id(:home)}
          end
        end
      end

      it "should require login to access the #{action} action" do
        logout
        expect { send(:get, action, @parameters.call) }.to require_login
      end

      it "should allow access to admins for the #{action} action" do
        expect {
          send(:get, action, @parameters.call)
        }.to restrict_access(allow: [users(:admin)],
                                 url: '/admin/pages')
      end

      it "should allow access to designers for the #{action} action" do
        expect {
          send(:get, action, @parameters.call)
        }.to restrict_access(allow: [users(:designer)],
                                 url: '/admin/pages')
      end

      it "should allow non-designers and non-admins for the #{action} action" do
        expect {
          send(:get, action, @parameters.call)
        }.to restrict_access(allow: [users(:non_admin), users(:existing)],
                                 url: '/admin/pages')
      end
    end
  end

  describe '#preview' do

    let(:preview_page){ pages(:home, :with_parts) }
    let(:body_id){ preview_page.part('body').id }
    let(:preview_params){
      {'page' => {
        'title' => 'BOGUS',
        'id' => preview_page.id.to_s,
        'parts_attributes' => [{'content' => 'TEST', 'id' => body_id.to_s}] } }
    }
    it 'should render the page with changes' do
      allow(request).to receive(:referer).and_return("/admin/pages/#{preview_page.id}/edit")
      post :preview, preview_params
      expect(response.body).to eql('TEST')
    end

    describe 'new child' do
      it 'should not save any changes' do
        page_count = Page.count
        allow(request).to receive(:referer).and_return("/admin/pages/#{preview_page.id}/edit")
        post :preview, preview_params
        expect(Page.count).to eq(page_count)
      end
    end
    # TODO: transactional fixtures must be turned off for this to be able to test the transactions properly
    # describe 'edit existing page' do
    #   it 'should not save any changes' do
    #     request.stub(:referer).and_return("/admin/pages/#{preview_page.id}/edit")
    #     original_date = preview_page.updated_at
    #     put :preview, preview_params
    #     non_updated_page = Page.find(preview_page.id)
    #     non_updated_page.title.should_not == 'BOGUS'
    #     non_updated_page.updated_at.to_i.should == original_date.to_i
    #   end
    # end
  end

  describe "prompting page removal" do


    # TODO: This should be in a view or integration spec
    it "should render the expanded descendants of the page being removed" do
      get :remove, id: page_id(:parent), format: 'html' # shouldn't need this!
      rendered_pages = [:parent, :child, :grandchild, :great_grandchild, :child_2, :child_3].map {|p| pages(p) }
      rendered_pages.each do |page|
        expect(response).to have_tag("tr#page_#{page.id}")
      end
    end
  end

  describe '#new' do
    it "should initialize meta and buttons_partials in new action" do
      get :new, page_id: page_id(:home)
      expect(response).to be_success
      expect(assigns(:meta)).to be_kind_of(Array)
      expect(assigns(:buttons_partials)).to be_kind_of(Array)
    end

    it "should set the parent_id from the parameters" do
      get :new, page_id: page_id(:home)
      expect(assigns(:page).parent_id).to eq(page_id(:home))
    end

    it "should set the @page variable" do
      home = pages(:home)
      new_page = home.class.new_with_defaults
      new_page.parent_id = home.id
      allow(Page).to receive(:new_with_defaults).and_return(new_page)
      get :new, page_id: home.id
      expect(assigns(:page)).to eq(new_page)
    end

     it "should create a page based on the given param" do
       get :new, page_id: page_id(:home), page_class: 'FileNotFoundPage'
       expect(assigns(:page)).to be_a(FileNotFoundPage)
     end

     it "should gracefully handle bogus page params" do
       get :new, page_id: page_id(:home), page_class: 'BogusPage'
       expect(assigns(:page)).to be_a(Page)
     end

     it "should instantiate a new page of the given class" do
       PagesControllerSpecPage = Class.new(Page)
       allow(PagesControllerSpecPage).to receive(:default_page_parts).and_return(PagePart.new name: "my_part")
       get :new, page_id: page_id(:home), page_class: 'PagesControllerSpecPage'
       expect(assigns(:page).parts.map(&:name)).to include('my_part')
     end
  end

  describe '#update' do
    it 'should update the page updated_at on every update' do
      start_updated_at = pages(:home).updated_at
      put :update, id: page_id(:home), page: {breadcrumb: 'Homepage'} and sleep(1)
      next_updated_at = pages(:home).updated_at
      expect{ start_updated_at <=> next_updated_at }.to be_truthy
      put :update, id: page_id(:home), page: {breadcrumb: 'Homepage'} and sleep(1)
      final_updated_at = pages(:home).updated_at
      expect{ next_updated_at <=> final_updated_at }.to be_truthy
    end

    if RUBY_VERSION =~ /1\.9/
      it 'should convert form input to UTF-8' do
        # When using Radiant with Ruby 1.9, the strings that come in from forms are ASCII-8BIT encoded.
        # That causes problems, especially when using special chars and with certain DBs, like DB2
        #
        # See http://stackoverflow.com/questions/8268778/rails-2-3-9-encoding-of-query-parameters
        # See https://rails.lighthouseapp.com/projects/8994/tickets/4807
        # See http://jasoncodes.com/posts/ruby19-rails2-encodings

        put :update, id: page_id(:home), page: {breadcrumb: 'Homepage', parts_attributes: {'0' => {id: pages(:home).parts[0].id, content: 'Ümlautö'.force_encoding('ASCII-8BIT')}}} and sleep(1)
        expect(params['page']['parts_attributes']['0']['content'].encoding.to_s).to eq('UTF-8')
        expect(params['page']['parts_attributes']['0']['content']).to eq('Ümlautö')
      end
    end
  end

  it "should initialize meta and buttons_partials in edit action" do
    get :edit, id: page_id(:home)
    expect(response).to be_success
    expect(assigns(:meta)).to be_kind_of(Array)
    expect(assigns(:buttons_partials)).to be_kind_of(Array)
  end

  it "should clear the page cache when saved" do
    expect(Radiant::Cache).to receive(:clear)
    put :update, id: page_id(:home), page: {breadcrumb: 'Homepage'}
  end

  describe "@body_classes" do
    it "should return 'reversed' when the action_name is 'new'" do
      get :new
      expect(assigns[:body_classes]).to eq(['reversed'])
    end
    it "should return 'reversed' when the action_name is 'edit'" do
      get :edit, id: 1
      expect(assigns[:body_classes]).to eq(['reversed'])
    end
    it "should return 'reversed' when the action_name is 'create'" do
      post :create
      expect(assigns[:body_classes]).to eq(['reversed'])
    end
    it "should return 'reversed' when the action_name is 'update'" do
      put :update, id: 1
      expect(assigns[:body_classes]).to eq(['reversed'])
    end
  end

  protected

    def assert_rendered_nodes_where(&block)
      wanted, unwanted = Page.all.partition(&block)
      wanted.each do |page|
        expect(response).to have_tag("tr[id=page_#{page.id}]")
      end
      unwanted.each do |page|
        expect(response).not_to have_tag("tr[id=page_#{page.id}]")
      end
    end

    def write_cookie(name, value)
      request.cookies[name] = value
    end
end

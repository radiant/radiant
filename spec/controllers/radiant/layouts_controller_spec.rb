require File.dirname(__FILE__) + "/../../spec_helper"

describe Radiant::Admin::LayoutsController do
  routes { Radiant::Engine.routes }
  #dataset :users, :pages_with_layouts
  include AuthenticationHelper
  
  let(:layout){ FactoryGirl.create(:layout) }
  let(:utf8_layout){ FactoryGirl.create(:utf8_layout) }
  let(:admin){ FactoryGirl.create(:admin) }
  let(:non_admin){ FactoryGirl.create(:user) }
  let(:designer){ FactoryGirl.create(:designer) }
  
  before :each do
    login_as designer
  end

  it "should be a ResourceController" do
    expect(controller).to be_kind_of(Radiant::Admin::ResourceController)
  end

  it "should handle Layouts" do
    expect(controller.class.model_class).to eq(Layout)
  end


  describe "show" do
    it "should redirect to the edit action" do
      get :show, id: 1
      expect(response).to redirect_to(edit_admin_layout_path(1))
    end

    it "should show xml when format is xml" do
      get :show, id: layout.id, format: "xml"
      expect(response.body).to eq(layout.to_xml)
    end
  end

  describe "with invalid page id" do
    [:edit, :remove].each do |action|
      before do
        @parameters = {id: 999}
      end
      it "should redirect the #{action} action to the index action" do
        get action, @parameters
        expect(response).to redirect_to(admin_layouts_path)
      end
      it "should say that the 'Layout could not be found.' after the #{action} action" do
        get action, @parameters
        expect(flash[:notice]).to eq('Layout could not be found.')
      end
    end
    it 'should redirect the update action to the index action' do
      put :update, @parameters
      expect(response).to redirect_to(admin_layouts_path)
    end
    it "should say that the 'Layout could not be found.' after the update action" do
      put :update, @parameters
      expect(flash[:notice]).to eq('Layout could not be found.')
    end
    it 'should redirect the destroy action to the index action' do
      delete :destroy, @parameters
      expect(response).to redirect_to(admin_layouts_path)
    end
    it "should say that the 'Layout could not be found.' after the destroy action" do
      delete :destroy, @parameters
      expect(flash[:notice]).to eq('Layout could not be found.')
    end
  end

  { get: [:index, :new, :edit, :remove],
    post: [:create],
    put: [:update],
    delete: [:destroy] }.each do |method, actions|
    actions.each do |action|
      it "should require login to access the #{action} action" do
        logout
        lambda { expect(send(method, action)).to require_login }
      end

      it "should allow access to designers for the #{action} action" do
        expect {
          send(method, action, id: layout.id)
        }.to restrict_access(allow: [designer],
                                 url: '/admin/pages')
      end

      it "should allow access to admins for the #{action} action" do
        expect {
          send(method, action, id: layout.id)
        }.to restrict_access(allow: [designer],
                                 url: '/admin/pages')
      end

      it "should deny non-designers and non-admins for the #{action} action" do
        expect {
          send(method, action, id: layout.id)
        }.to restrict_access(deny: non_admin,
                                 url: '/admin/pages')
      end
    end
  end

  it "should clear the page cache when saved" do
    expect(Radiant::Cache).to receive(:clear)
    put :update, id: utf8_layout.id, layout: {content_type: "application/xhtml+xml;charset=utf8"}
  end

end

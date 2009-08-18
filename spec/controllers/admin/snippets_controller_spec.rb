require File.dirname(__FILE__) + "/../../spec_helper"

describe Admin::SnippetsController do
  dataset :users, :snippets

  before :each do
    ActionController::Routing::Routes.reload
    login_as :existing
  end

  it "should be an ResourceController" do
    controller.should be_kind_of(Admin::ResourceController)
  end

  it "should handle Snippets" do
    controller.class.model_class.should == Snippet
  end


  describe "show" do
    it "should redirect to the edit action" do
      get :show, :id => 1
      response.should redirect_to(edit_admin_snippet_path(params[:id]))
    end

    it "should show xml when format is xml" do
      snippet = Snippet.first
      get :show, :id => snippet.id, :format => "xml"
      response.body.should == snippet.to_xml
    end
  end

  describe "with invalid snippet id" do
    [:edit, :remove].each do |action|
      before do
        @parameters = {:id => 999}
      end
      it "should redirect the #{action} action to the index action" do
        get action, @parameters
        response.should redirect_to(admin_snippets_path)
      end
      it "should say that the 'Snippet could not be found.' after the #{action} action" do
        get action, @parameters
        flash[:notice].should == 'Snippet could not be found.'
      end
    end
    it 'should redirect the update action to the index action' do
      put :update, @parameters
      response.should redirect_to(admin_snippets_path)
    end
    it "should say that the 'Snippet could not be found.' after the update action" do
      put :update, @parameters
      flash[:notice].should == 'Snippet could not be found.'
    end
    it 'should redirect the destroy action to the index action' do
      delete :destroy, @parameters
      response.should redirect_to(admin_snippets_path)
    end
    it "should say that the 'Snippet could not be found.' after the destroy action" do
      delete :destroy, @parameters
      flash[:notice].should == 'Snippet could not be found.'
    end
  end

  {:get => [:index, :show, :new, :edit, :remove],
   :post => [:create],
   :put => [:update],
   :delete => [:destroy]}.each do |method, actions|
    actions.each do |action|
      it "should require login to access the #{action} action" do
        logout
        lambda { send(method, action, :id => snippet_id(:first)) }.should require_login
      end

      if action == :show
        it "should request authentication for API access on show" do
          logout
          send(method, action, :id => snippet_id(:first), :format => "xml")
          response.response_code.should == 401
        end
      else
        it "should allow access to developers for the #{action} action" do
          lambda {
            send(method, action, :id => snippet_id(:first))
          }.should restrict_access(:allow => [users(:developer)],
                                  :url => '/admin/pages')
        end

        it "should allow access to admins for the #{action} action" do
          lambda {
            send(method, action, :id => snippet_id(:first))
          }.should restrict_access(:allow => [users(:developer)],
                                   :url => '/admin/pages')
        end

        it "should allow non-developers and non-admins for the #{action} action" do
          lambda {
            send(method, action, :id => Snippet.first.id)
          }.should restrict_access(:allow => [users(:non_admin), users(:existing)],
                                   :url => '/admin/pages')
        end
      end
    end
  end

  it "should clear the page cache when saved" do
    Radiant::Cache.should_receive(:clear)
    put :update, :id => snippet_id(:first), :snippet => {:content => "Foobar."}
  end
end

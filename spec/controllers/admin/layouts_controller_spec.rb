require File.dirname(__FILE__) + "/../../spec_helper"

describe Admin::LayoutsController do
  dataset :users, :pages_with_layouts

  before :each do
    login_as :developer
  end

  it "should be a ResourceController" do
    controller.should be_kind_of(Admin::ResourceController)
  end

  it "should handle Layouts" do
    controller.class.model_class.should == Layout
  end
  
  
  describe "show" do
    it "should redirect to the edit action" do
      get :show, :id => 1
      response.should redirect_to(edit_admin_layout_path(params[:id]))
    end
  end
  
  describe "with invalid page id" do
    [:edit, :remove].each do |action|
      before do
        @parameters = {:id => 999}
      end
      it "should redirect the #{action} action to the index action" do
        get action, @parameters
        response.should redirect_to(admin_layouts_path)
      end
      it "should say that the 'Layout could not be found.' after the #{action} action" do
        get action, @parameters
        flash[:notice].should == 'Layout could not be found.'
      end
    end
    it 'should redirect the update action to the index action' do
      put :update, @parameters
      response.should redirect_to(admin_layouts_path)
    end
    it "should say that the 'Layout could not be found.' after the update action" do
      put :update, @parameters
      flash[:notice].should == 'Layout could not be found.'
    end
    it 'should redirect the destroy action to the index action' do
      delete :destroy, @parameters
      response.should redirect_to(admin_layouts_path)
    end
    it "should say that the 'Layout could not be found.' after the destroy action" do
      delete :destroy, @parameters
      flash[:notice].should == 'Layout could not be found.'
    end
  end

  { :get => [:index, :new, :edit, :remove],
    :post => [:create],
    :put => [:update],
    :delete => [:destroy] }.each do |method, actions|
    actions.each do |action|
      it "should require login to access the #{action} action" do
        logout
        lambda { send(method, action).should require_login }
      end

      it "should allow access to developers for the #{action} action" do
        lambda { 
          send(method, action, :id => layout_id(:main)) 
        }.should restrict_access(:allow => [users(:developer)], 
                                 :url => '/admin/pages')
      end

      it "should allow access to admins for the #{action} action" do
        lambda { 
          send(method, action, :id => layout_id(:main)) 
        }.should restrict_access(:allow => [users(:developer)], 
                                 :url => '/admin/pages')
      end
      
      it "should deny non-developers and non-admins for the #{action} action" do
        lambda { 
          send(method, action, :id => layout_id(:main)) 
        }.should restrict_access(:deny => [users(:non_admin), users(:existing)],
                                 :url => '/admin/pages')
      end
    end
  end

  it "should clear the page cache when saved" do
    Radiant::Cache.should_receive(:clear)
    put :update, :id => layout_id(:utf8), :layout => {:content_type => "application/xhtml+xml;charset=utf8"}
  end

end

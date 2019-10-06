require File.dirname(__FILE__) + "/../../spec_helper"

describe Admin::UsersController do
  dataset :users
  
  it "should be a ResourceController" do
    controller.should be_kind_of(Admin::ResourceController)
  end

  it "should handle Users" do
    controller.class.model_class.should == User
  end
  
  
  describe "show" do
    it "should redirect to the edit action" do
      login_as :admin
      get :show, :id => 1
      response.should redirect_to(edit_admin_user_path(params[:id]))
    end
  end
  
  describe "with invalid page id" do
    before do
      login_as :admin
    end
    [:edit, :remove].each do |action|
      before do
        @parameters = {:id => 999}
      end
      it "should redirect the #{action} action to the index action" do
        get action, @parameters
        response.should redirect_to(admin_users_path)
      end
      it "should say that the 'User could not be found.' after the #{action} action" do
        get action, @parameters
        flash[:notice].should == 'User could not be found.'
      end
    end
    it 'should redirect the update action to the index action' do
      put :update, @parameters
      response.should redirect_to(admin_users_path)
    end
    it "should say that the 'User could not be found.' after the update action" do
      put :update, @parameters
      flash[:notice].should == 'User could not be found.'
    end
    it 'should redirect the destroy action to the index action' do
      delete :destroy, @parameters
      response.should redirect_to(admin_users_path)
    end
    it "should say that the 'User could not be found.' after the destroy action" do
      delete :destroy, @parameters
      flash[:notice].should == 'User could not be found.'
    end
  end

  { :get => [:index, :new, :edit, :remove],
    :post => [:create],
    :put => [:update],
    :delete => [:destroy] }.each do |method, actions|
    actions.each do |action|
      it "should require login to access the #{action} action" do
        logout
        lambda { send(method, action, :id => user_id(:existing)).should require_login }
      end

      it "should allow you to access to #{action} action if you are an admin" do
        lambda { 
          send(method, action, :id => user_id(:existing)) 
        }.should restrict_access(:allow => users(:admin),
                                 :url => '/admin/page')
      end
      
      it "should deny you access to #{action} action if you are not an admin" do
        lambda { 
          send(method, action, :id => user_id(:existing)) 
        }.should restrict_access(:deny => [users(:designer), users(:existing)],
                                 :url => '/admin/page')
      end
    end
  end

  it "should not allow you to delete yourself" do
    user = users(:admin)
    login_as user
    get :remove, { :id => user.id }
    response.should redirect_to(admin_users_url)
    flash[:error].should match(/cannot.*self/i)
    User.find(user.id).should_not be_nil
  end 

  it "should not allow you to remove your own admin privilege" do
    user = users(:admin)
    login_as user
    put :update, { :id => user.id, :user => {:admin => false} }
    response.should redirect_to(admin_users_url)
    flash[:error].should match(/cannot remove yourself from the admin role/i)
    User.find(user.id).admin.should be_true
  end  
end

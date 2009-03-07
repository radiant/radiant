require File.dirname(__FILE__) + "/../../spec_helper"

describe Admin::UsersController do
  dataset :users
  
  it "should be a ResourceController" do
    controller.should be_kind_of(Admin::ResourceController)
  end

  it "should handle Users" do
    controller.class.model_class.should == User
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
        }.should restrict_access(:deny => [users(:developer), users(:existing)],
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
end

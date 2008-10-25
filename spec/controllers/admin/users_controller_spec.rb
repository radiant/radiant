require File.dirname(__FILE__) + "/../../spec_helper"

describe Admin::UsersController do
  scenario :users
  test_helper :logging
  
  integrate_views
  
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
        lambda { send(method, action).should require_login }
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
  
#   it "should allow you to view your preferences" do
#     user = login_as(:non_admin)
#     get :preferences, :user => { :email => 'updated@email.com' }
#     response.should be_success
#     assigned_user = assigns(:user)
#     assigned_user.should == user
#     assigned_user.object_id.should_not == user.object_id
#     assigned_user.email.should == 'non_admin@example.com'
#   end

#   it "should allow you to save your preferences" do
#     login_as :non_admin
#     post :preferences, :user => { :password => '', :password_confirmation => '', :email => 'updated@gmail.com' }
#     user = users(:non_admin)
#     response.should redirect_to(page_index_url)
#     flash[:notice].should match(/preferences.*?saved/i)
#     user.email.should == 'updated@gmail.com'
#   end

#   it "should not allow you to update your login through the preferences page" do
#     login_as :non_admin
#     get :preferences, 'user' => { :login => 'superman' }
#     response.should be_success
#     flash[:error].should match(/bad form data/i)
#   end
  
#   it "should allow you to change your password" do
#     login_as :non_admin
#     post :preferences, { :user => { :password => 'funtimes', :password_confirmation => 'funtimes' } }
#     user = users(:non_admin)
#     user.password.should == user.sha1('funtimes')
    
#     rails_log.should_not match(/"password"=>"funtimes"/)
#     rails_log.should_not match(/"password_confirmation"=>"funtimes"/)
#   end
  
end

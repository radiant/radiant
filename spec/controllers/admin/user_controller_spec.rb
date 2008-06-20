require File.dirname(__FILE__) + "/../../spec_helper"

describe Admin::UserController do
  scenario :users
  test_helper :logging
  
  integrate_views
  
  it "should inherit from the abstract model controller" do
    Admin::UserController.ancestors.should include(Admin::AbstractModelController)
  end
  
  [:index, :new, :edit, :remove, :preferences].each do |action|
    it "should require you to login in order to access #{action}" do
      lambda { get action }.should require_login
    end
  end
  
  [:index, :new, :edit, :remove].each do |action|
    it "should allow you to access to #{action} action if you are an admin" do
      lambda { get action, :id => user_id(:existing) }.should restrict_access(:allow => users(:admin))
    end
    
    it "should deny you access to #{action} action if you are not an admin" do
      lambda { get action, :id => user_id(:existing) }.should restrict_access(:deny => [users(:developer), users(:existing)])
    end
  end
  
  it "should not allow you to delete yourself" do
    user = users(:admin)
    login_as user
    get :remove, { :id => user.id }
    response.should redirect_to(user_index_url)
    flash[:error].should match(/cannot.*self/i)
    User.find(user.id).should_not be_nil
  end
  
  it "should allow you to view your preferences" do
    user = login_as(:non_admin)
    get :preferences, :user => { :email => 'updated@email.com' }
    response.should be_success
    assigned_user = assigns(:user)
    assigned_user.should == user
    assigned_user.object_id.should_not == user.object_id
    assigned_user.email.should == 'non_admin@example.com'
  end
  it "should allow you to save your preferences" do
    login_as :non_admin
    post :preferences, :user => { :password => '', :password_confirmation => '', :email => 'updated@gmail.com' }
    user = users(:non_admin)
    response.should redirect_to(page_index_url)
    flash[:notice].should match(/preferences.*?saved/i)
    user.email.should == 'updated@gmail.com'
  end
  it "should not allow you to update your login through the preferences page" do
    login_as :non_admin
    get :preferences, 'user' => { :login => 'superman' }
    response.should be_success
    flash[:error].should match(/bad form data/i)
  end
  
  it "should allow you to change your password" do
    login_as :non_admin
    post :preferences, { :user => { :password => 'funtimes', :password_confirmation => 'funtimes' } }
    user = users(:non_admin)
    user.password.should == user.sha1('funtimes')
    
    rails_log.should_not match(/"password"=>"funtimes"/)
    rails_log.should_not match(/"password_confirmation"=>"funtimes"/)
  end
  
end
require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe Admin::PreferencesController do
  dataset :users
  
  it "should allow you to view your preferences" do
    user = login_as(:non_admin)
    get :edit
    response.should be_success
    assigned_user = assigns(:user)
    assigned_user.should == user
    assigned_user.object_id.should_not == user.object_id
    assigned_user.email.should == 'non_admin@example.com'
  end

  it "should allow you to save your preferences" do
    login_as :non_admin
    put :update, :user => { :password => '', :password_confirmation => '', :email => 'updated@gmail.com' }
    user = users(:non_admin)
    response.should redirect_to(admin_pages_path)
    flash[:notice].should match(/preferences.*?updated/i)
    user.email.should == 'updated@gmail.com'
  end

  it "should not allow you to update your login through the preferences page" do
    login_as :non_admin
    put :update, 'user' => { :login => 'superman' }
    response.should be_success
    flash[:error].should match(/bad form data/i)
  end
  
  it "should allow you to change your password" do
    login_as :non_admin
    put :update, { :user => { :password => 'funtimes', :password_confirmation => 'funtimes' } }
    user = users(:non_admin)
    user.password.should == user.sha1('funtimes')
    
    rails_log.should_not match(/"password"=>"funtimes"/)
    rails_log.should_not match(/"password_confirmation"=>"funtimes"/)
  end
end

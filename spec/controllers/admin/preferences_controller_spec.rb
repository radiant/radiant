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
    response.should redirect_to(admin_configuration_path)
    user.email.should == 'updated@gmail.com'
  end

  it "should not allow you to update your role through the preferences page" do
    login_as :non_admin
    put :update, 'user' => { :admin => true }
    response.should be_success
    flash[:error].should match(/bad form data/i)
  end
  
  it "should allow you to change your password" do
    login_as :non_admin
    put :update, { :user => { :password => 'funtimes', :password_confirmation => 'funtimes' } }
    user = users(:non_admin)
    user.password.should == user.sha1('funtimes')
  end
  
  it "should use the User.unprotected_attributes for checking valid_params?" do
    User.should_receive(:unprotected_attributes).at_least(:once).and_return([:password, :password_confirmation, :email])
    login_as :non_admin
    put :update, { :user => { :password => 'funtimes', :password_confirmation => 'funtimes' } }
  end
  
  describe "@body_classes" do
    before do
      login_as(:non_admin)
    end
    it "should return 'reversed' when the action_name is 'edit'" do
      get :edit
      assigns[:body_classes].should == ['reversed']
    end
    it "should return 'reversed' when the action_name is 'show'" do
      get :show
      assigns[:body_classes].should == ['reversed']
    end
  end
end

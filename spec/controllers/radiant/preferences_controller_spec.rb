require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe Radiant::Admin::PreferencesController do
  routes { Radiant::Engine.routes }
  #dataset :users

  it "should allow you to view your preferences" do
    user = login_as(:non_admin)
    get :edit
    expect(response).to be_success
    assigned_user = assigns(:user)
    expect(assigned_user).to eq(user)
    expect(assigned_user.object_id).not_to eq(user.object_id)
    expect(assigned_user.email).to eq('non_admin@example.com')
  end

  it "should allow you to save your preferences" do
    login_as :non_admin
    put :update, user: { password: '', password_confirmation: '', email: 'updated@gmail.com' }
    user = users(:non_admin)
    expect(response).to redirect_to(admin_configuration_path)
    expect(user.email).to eq('updated@gmail.com')
  end

  it "should not allow you to update your role through the preferences page" do
    login_as :non_admin
    put :update, 'user' => { admin: true }
    expect(response).to be_success
    expect(flash[:error]).to match(/bad form data/i)
  end

  it "should allow you to change your password" do
    login_as :non_admin
    put :update, { user: { password: 'funtimes', password_confirmation: 'funtimes' } }
    user = users(:non_admin)
    expect(user.password).to eq(user.sha1('funtimes'))
  end

  it "should use the User.unprotected_attributes for checking valid_params?" do
    expect(User).to receive(:unprotected_attributes).at_least(:once).and_return([:password, :password_confirmation, :email])
    login_as :non_admin
    put :update, { user: { password: 'funtimes', password_confirmation: 'funtimes' } }
  end

  describe "@body_classes" do
    before do
      login_as(:non_admin)
    end
    it "should return 'reversed' when the action_name is 'edit'" do
      get :edit
      expect(assigns[:body_classes]).to eq(['reversed'])
    end
    it "should return 'reversed' when the action_name is 'show'" do
      get :show
      expect(assigns[:body_classes]).to eq(['reversed'])
    end
  end
end

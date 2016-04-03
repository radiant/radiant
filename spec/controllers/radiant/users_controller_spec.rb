require File.dirname(__FILE__) + "/../../spec_helper"

describe Radiant::Admin::UsersController do
  routes { Radiant::Engine.routes }
  #dataset :users

  it "should be a ResourceController" do
    expect(controller).to be_kind_of(Radiant::ResourceController)
  end

  it "should handle Users" do
    expect(controller.class.model_class).to eq(User)
  end


  describe "show" do
    it "should redirect to the edit action" do
      login_as :admin
      get :show, id: 1
      expect(response).to redirect_to(edit_admin_user_path(params[:id]))
    end
  end

  describe "with invalid page id" do
    before do
      login_as :admin
    end
    [:edit, :remove].each do |action|
      before do
        @parameters = {id: 999}
      end
      it "should redirect the #{action} action to the index action" do
        get action, @parameters
        expect(response).to redirect_to(admin_users_path)
      end
      it "should say that the 'User could not be found.' after the #{action} action" do
        get action, @parameters
        expect(flash[:notice]).to eq('User could not be found.')
      end
    end
    it 'should redirect the update action to the index action' do
      put :update, @parameters
      expect(response).to redirect_to(admin_users_path)
    end
    it "should say that the 'User could not be found.' after the update action" do
      put :update, @parameters
      expect(flash[:notice]).to eq('User could not be found.')
    end
    it 'should redirect the destroy action to the index action' do
      delete :destroy, @parameters
      expect(response).to redirect_to(admin_users_path)
    end
    it "should say that the 'User could not be found.' after the destroy action" do
      delete :destroy, @parameters
      expect(flash[:notice]).to eq('User could not be found.')
    end
  end

  { get: [:index, :new, :edit, :remove],
    post: [:create],
    put: [:update],
    delete: [:destroy] }.each do |method, actions|
    actions.each do |action|
      it "should require login to access the #{action} action" do
        logout
        lambda { expect(send(method, action, id: user_id(:existing))).to require_login }
      end

      it "should allow you to access to #{action} action if you are an admin" do
        expect {
          send(method, action, id: user_id(:existing))
        }.to restrict_access(allow: FactoryGirl.create(:admin),
                                 url: '/admin/page')
      end

      it "should deny you access to #{action} action if you are not an admin" do
        expect {
          send(method, action, id: user_id(:existing))
        }.to restrict_access(deny: [FactoryGirl.create(:designer), FactoryGirl.create(:existing)],
                                 url: '/admin/page')
      end
    end
  end

  it "should not allow you to delete yourself" do
    user = FactoryGirl.create(:admin)
    login_as user
    get :remove, { id: user.id }
    expect(response).to redirect_to(admin_users_url)
    expect(flash[:error]).to match(/cannot.*self/i)
    expect(User.find(user.id)).not_to be_nil
  end

  it "should not allow you to remove your own admin privilege" do
    user = FactoryGirl.create(:admin)
    login_as user
    put :update, { id: user.id, user: {admin: false} }
    expect(response).to redirect_to(admin_users_url)
    expect(flash[:error]).to match(/cannot remove yourself from the admin role/i)
    expect(User.find(user.id).admin).to be_truthy
  end
end

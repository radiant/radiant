require File.dirname(__FILE__) + "/../../spec_helper"

describe Radiant::Admin::WelcomeController do
  routes { Radiant::Engine.routes }
  #dataset :users

  it "should redirect to page tree on get to /admin/welcome" do
    get :index
    expect(response).to be_redirect
    expect(response).to redirect_to(admin_pages_path)
  end

  it "should render the login screen on get to /admin/login" do
    get :login
    expect(response).to be_success
    expect(response).to render_template("login")
  end

  it "should set the current user and redirect when login was successful" do
    users(:admin) # ensure the user exists
    post :login, username_or_email: "admin", password: "password"
    expect(controller.send(:current_user)).to eq(users(:admin))
    expect(response).to be_redirect
    expect(response).to redirect_to(welcome_url)
  end

  it "should render the login template when login failed" do
    expect(controller).to receive(:announce_invalid_user) # Can't test flash.now!
    post :login, user: {login: "admin", password: "wrong"}
    expect(response).to render_template("login")
  end

  describe "remember me" do

    before do
      Radiant::Config['session_timeout'] = 2.weeks
      @user = users(:admin)
      allow(controller).to receive(:current_user).and_return(@user)
    end

    after do
      post :login, username_or_email: "admin", password: "password", remember_me: 1
    end

    it "should remember user" do
      expect(@user).to receive(:remember_me)
    end

    it "should set cookie" do
      expect(controller).to receive(:set_session_cookie)
    end
  end

  describe "with a logged-in user" do
    before do
      login_as :admin
    end

    it "should clear the current user and redirect on logout" do
      expect(controller).to receive(:current_user=).with(nil)
      get :logout
      expect(response).to be_redirect
      expect(response).to redirect_to(login_url)
    end

    it "should forget user on logout" do
      expect(controller.send(:current_user)).to receive(:forget_me)
      get :logout
    end

    it "should not show /login again" do
      get :login
      expect(response).to redirect_to(welcome_url)
    end

    describe "and a stored location" do
      before do
        session[:return_to] = '/stored/path'
        post :login, username_or_email: "admin", password: "password"
      end

      it "should redirect" do
        expect(response).to redirect_to('/stored/path')
      end

      it "should clear session[:return_to]" do
        expect(session[:return_to]).to be_nil
      end
    end
  end

  describe "without a user" do
    it "should gracefully handle logout" do
      allow(controller).to receive(:current_member).and_return(nil)
      get :logout
      expect(response).to redirect_to(login_url)
    end
  end

end
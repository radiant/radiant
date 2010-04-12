require File.dirname(__FILE__) + "/../../spec_helper"

describe Admin::WelcomeController do
  dataset :users
  
  it "should redirect to page tree on get to /admin/welcome" do
    get :index
    response.should be_redirect
    response.should redirect_to(admin_pages_path)
  end
  
  it "should render the login screen on get to /admin/login" do
    get :login
    response.should be_success
    response.should render_template("login")
  end
  
  it "should set the current user and redirect when login was successful" do
    post :login, :username_or_email => "admin", :password => "password"
    controller.send(:current_user).should == users(:admin)
    response.should be_redirect
    response.should redirect_to(welcome_url)
  end
  
  it "should render the login template when login failed" do
    controller.should_receive(:announce_invalid_user) # Can't test flash.now!
    post :login, :user => {:login => "admin", :password => "wrong"}
    response.should render_template("login")
  end
  
  describe "remember me" do

    before do
      Radiant::Config['session_timeout'] = 2.weeks
      @user = users(:admin)
      controller.stub!(:current_user).and_return(@user)
    end

    after do
      post :login, :username_or_email => "admin", :password => "password", :remember_me => 1
    end

    it "should remember user" do
      @user.should_receive(:remember_me)
    end

    it "should set cookie" do
      controller.should_receive(:set_session_cookie)
    end
  end

  describe "with a logged-in user" do
    before do
      login_as :admin
    end

    it "should clear the current user and redirect on logout" do
      controller.should_receive(:current_user=).with(nil)
      get :logout
      response.should be_redirect
      response.should redirect_to(login_url)
    end

    it "should forget user on logout" do
      controller.send(:current_user).should_receive(:forget_me)
      get :logout
    end

    it "should not show /login again" do
      get :login
      response.should redirect_to(welcome_url)
    end

    describe "and a stored location" do
      before do
        session[:return_to] = '/stored/path'
        post :login, :username_or_email => "admin", :password => "password"
      end

      it "should redirect" do
        response.should redirect_to('/stored/path')
      end

      it "should clear session[:return_to]" do
        session[:return_to].should be_nil
      end
    end
  end

  describe "without a user" do
    it "should gracefully handle logout" do
      controller.stub!(:current_member).and_return(nil)
      get :logout
      response.should redirect_to(login_url)
    end
  end

end
require File.dirname(__FILE__) + "/../spec_helper"

class StubController < ActionController::Base
  include LoginSystem
  
  def rescue_action(e) raise e end
  
  def method_missing(method, *args, &block)
    if (args.size == 0) and not block_given?
      render :text => 'just a test' unless @performed_render || @performed_redirect
    else
      super
    end
  end
end

describe 'Login System:', :type => :controller do
  dataset :users
  
  before do
    map = ActionController::Routing::RouteSet::Mapper.new(ActionController::Routing::Routes)
    map.connect ':controller/:action/:id'
    ActionController::Routing::Routes.named_routes.install
  end

  after do
    ActionController::Routing::Routes.reload
  end

  describe NoLoginRequiredController = StubController.subclass('NoLoginRequiredController') { no_login_required } do
    it "should not require authentication" do
      get :index
      response.should be_success
    end
  end

  describe LoginRequiredController = StubController.subclass('LoginRequiredController') { }, :type => :controller do
    it "should authenticate with user in session" do
      login_as :existing
      get :index
      response.should be_success
    end

    it "should not authenicate without user in session" do
      get :index
      response.should redirect_to(login_url)
    end

    it "should store location" do
      session[:return_to] = nil
      get 'protected_action'
      session[:return_to].should match(%r{protected_action})
    end
  end

  describe StubController do
    
    describe ".authenticate" do
      it "should attempt to login from cookie" do
        controller.should_receive(:login_from_cookie)
        get :action
      end
    end

    describe ".login_from_cookie" do
      before do
        Time.zone = 'UTC'
        Radiant::Config.stub!(:[]).with('session_timeout').and_return(2.weeks)
      end

      it "should not login user if no cookie found" do
        controller.should_not_receive(:current_user=)
        get :index
      end

      describe "with session_token" do
        before do
          @user = users(:admin)
          User.should_receive(:find_by_session_token).and_return(@user)
          @cookies = { :session_token => 12345 }
          controller.stub!(:cookies).and_return(@cookies)
        end

        after do
          controller.send :login_from_cookie
        end

        it "should log in user" do
          controller.should_receive(:current_user=).with(@user).and_return {
            # can't mock current_user before current_user= is
            # called, else the method doesn't run
            controller.stub!(:current_user).and_return(@user)
          }
        end

        it "should remember user" do
          @user.should_receive(:remember_me)
        end

        it "should update cookie" do
          @cookies.should_receive(:[]=) do |name,content|
            name.should eql(:session_token)
            content[:value].should eql(@user.session_token)
            content[:expires].should be_close((Time.zone.now + 2.weeks).utc, 1.minute) # sometimes specs are slow
          end
        end

      end
    end
  end

  describe NoLoginRequiredChildController = NoLoginRequiredController.subclass('NoLoginRequiredChildController') { } do
    it "should inherit no_login_required" do
      # StubController.controllers_where_no_login_required.should include(NoLoginRequiredChildController)
      controller.class.should_not be_login_required
    end
  end

  describe LoginRequiredGrandChildController = NoLoginRequiredChildController.subclass('LoginRequiredGrandChildController') {
      login_required
    } do
      it "should override parent with login_required" do
        controller.class.should be_login_required
      end
  end

  describe LoginRequiredGreatGrandChildController = LoginRequiredGrandChildController.subclass('LoginRequiredGreatGrandChildController') { } do
    it "should inherit login_required" do
      controller.class.should be_login_required
    end
  end

  describe LoginRequiredController.subclass('OnlyAllowAccessToWhenController') {
    only_allow_access_to :edit, :new, 
                         :when => [:admin, :developer], 
                         :denied_url => '/login_required', 
                         :denied_message => 'Fun.'
    } do
    it "should only allow access when user in roles" do
      login_as :admin
      get :edit
      response.should be_success
    end

    it "should not allow access when user not in roles" do
      login_as :non_admin
      get :edit
      response.should redirect_to('/login_required')
      flash[:error].should eql('Fun.')
    end

    it "should allow access to unrestricted actions when users not in roles" do
      login_as :non_admin
      get :another
      response.should be_success
    end
  end

  describe LoginRequiredController.subclass('OnlyAllowAccessToWhenDefaultsController') {
      only_allow_access_to :edit, 
                           :when => :admin, 
                           :denied_url => '/login_required', 
                           :denied_message => 'Fun.'
    } do
    it "should not allow access when user not in default roles" do
      login_as :non_admin
      get :edit
      response.should redirect_to('/login_required')
      flash[:error].should eql('Fun.')
    end
  end

  describe LoginRequiredController.subclass('OnlyAllowAccessToIfController') {
      attr_writer :condition
      define_method(:condition?, proc { @condition ||= false })
      only_allow_access_to :edit, :if => :condition?, 
                           :denied_url => '/login_required', 
                           :denied_message => 'Fun.'
    } do

    it "should allow access if condition is true" do
      controller.condition = true
      login_as :existing
      get :edit
      response.should be_success
    end

    it "should not allow access if condition is false" do
      controller.condition = false
      login_as :existing
      get :edit
      response.should redirect_to('/login_required')
    end
  end

end
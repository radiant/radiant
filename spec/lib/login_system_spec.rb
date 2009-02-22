require File.dirname(__FILE__) + "/../spec_helper"

class StubController < ActionController::Base
  include LoginSystem

  def rescue_action(e); raise e; end
  def index; render :text => 'just a test'; end
end

class NoLoginRequiredController < StubController;  no_login_required; end
class LoginRequiredController < StubController; end
class NoLoginRequiredChildController < NoLoginRequiredController; end
class LoginRequiredGrandChildController < NoLoginRequiredChildController; login_required; end
class PrivilegedUsersOnlyController < LoginRequiredController
  only_allow_access_to :edit, :new,
                       :when => [:admin, :developer],
                       :denied_url => '/login_required',
                       :denied_message => 'Fun.'
  def edit; render :text => 'just a test'; end
  def new; render :text => 'just a test'; end
end
class AdminOnlyController < LoginRequiredController
    only_allow_access_to :edit,
                         :when => :admin,
                         :denied_url => '/login_required',
                         :denied_message => 'Fun.'
    def edit; render :text => 'just a test'; end
end
class ConditionalAccessController < LoginRequiredController
    attr_writer :condition
    only_allow_access_to :edit, :if => :condition?,
                         :denied_url => '/login_required',
                         :denied_message => 'Fun.'

    def edit; render :text => 'just a test'; end
    def condition?
      @condition ||= false
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

  describe NoLoginRequiredController do
    it "should not require authentication" do
      get :index
      response.should be_success
    end
  end

  describe LoginRequiredController do
    it "should authenticate with user in session" do
      login_as :existing
      get :index
      response.should be_success
    end

    it "should not authenticate without user in session" do
      logout
      get :index
      response.should redirect_to(login_url)
    end

    it "should store location" do
      logout
      session[:return_to] = nil
      get 'protected_action'
      session[:return_to].should match(%r{protected_action})
    end
  end

  describe StubController do

    describe ".authenticate" do
      it "should attempt to login from cookie" do
        controller.should_receive(:login_from_cookie)
        get :index
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
          controller.send(:login_from_cookie).should == @user
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

  describe NoLoginRequiredChildController do
    it "should inherit no_login_required" do
      controller.class.should_not be_login_required
    end
  end

  describe LoginRequiredGrandChildController do
      it "should override parent with login_required" do
        controller.class.should be_login_required
      end
  end

  describe LoginRequiredGreatGrandChildController = Class.new(LoginRequiredGrandChildController) { } do
    it "should inherit login_required" do
      controller.class.should be_login_required
    end
  end

  describe PrivilegedUsersOnlyController do
    it "should only allow access when user in allowed roles" do
      login_as :admin
      get :edit
      response.should be_success
    end

    it "should deny access when user not in allowed roles" do
      login_as :non_admin
      get :edit
      response.should redirect_to('/login_required')
      flash[:error].should eql('Fun.')
    end

    it "should allow access to unrestricted actions when users not in roles" do
      login_as :non_admin
      get :index
      response.should be_success
    end
  end

  describe AdminOnlyController do
    it "should not allow access when user not in default roles" do
      login_as :non_admin
      get :edit
      response.should redirect_to('/login_required')
      flash[:error].should eql('Fun.')
    end
  end

  describe ConditionalAccessController do

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
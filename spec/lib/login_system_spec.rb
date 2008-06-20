require File.dirname(__FILE__) + "/../spec_helper"

class StubController < ActionController::Base
  include LoginSystem
  
  def rescue_action(e) raise e end
  
  def method_missing(method, *args, &block)
    if (args.size == 0) and not block_given?
      render :text => 'just a test'
    else
      super
    end
  end
end

class LoginRequiredController < StubController
end

class NoLoginRequiredController < StubController
  no_login_required
end

class NoLoginRequiredChildController < NoLoginRequiredController
end

class LoginRequiredGrandChildController < NoLoginRequiredChildController
  login_required
end

class LoginRequiredGreatGrandChildController < LoginRequiredGrandChildController
end

describe StubController do
  it "should add self to controllers_where_no_login_required" do
    StubController.controllers_where_no_login_required.should include(NoLoginRequiredController)
  end
  
  it "should inherit no_login_required" do
    StubController.controllers_where_no_login_required.should include(NoLoginRequiredChildController)
  end
  
  it "should override parent with login_required" do
    StubController.controllers_where_no_login_required.should_not include(LoginRequiredGrandChildController)
  end
  
  it "should inherit login_required" do
    StubController.controllers_where_no_login_required.should_not include(LoginRequiredGreatGrandChildController)
  end
end

describe NoLoginRequiredController, :type => :controller do
  it "should not require authentication" do
    get :index
    response.should be_success
  end
end

describe LoginRequiredController, :type => :controller do
  scenario :users

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
    get 'protected_action'
    session[:return_to].should match(/login_required\/protected_action/)
  end
end

class OnlyAllowAccessToWhenController < LoginRequiredController
  only_allow_access_to :edit, :new, :when => [:admin, :developer], :denied_url => { :action => :test }, :denied_message => 'Fun.'
end

describe OnlyAllowAccessToWhenController, :type => :controller do
  scenario :users
  
  it "should only allow access when user in roles" do
    login_as :admin
    get :edit
    response.should be_success
  end
  
  it "should not allow access when user not in roles" do
    login_as :non_admin
    get :edit
    response.should redirect_to(:action => :test)
    flash[:error].should eql('Fun.')
  end
  
  it "should allow access to unrestricted actions when users not in roles" do
    login_as :non_admin
    get :another
    response.should be_success
  end
end

class OnlyAllowAccessToWhenDefaultsController < LoginRequiredController
  only_allow_access_to :edit, :when => :admin, :denied_url => { :action => :test }, :denied_message => 'Fun.'
end

describe OnlyAllowAccessToWhenDefaultsController, :type => :controller do
  scenario :users
  
  it "should not allow access when user not in default roles" do
    login_as :non_admin
    get :edit
    response.should redirect_to(:action => :test)
    flash[:error].should eql('Fun.')
  end
end

class OnlyAllowAccessToIfController < LoginRequiredController
  attr_writer :condition
  
  def condition?
    @condition ||= false
  end
  
  only_allow_access_to :edit, :if => :condition?, :denied_url => { :action => :test }, :denied_message => 'Fun.'
end

describe OnlyAllowAccessToIfController, :type => :controller do
  scenario :users

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
    response.should redirect_to(:action => :test)
  end
end
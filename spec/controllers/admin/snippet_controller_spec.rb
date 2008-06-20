require File.dirname(__FILE__) + "/../../spec_helper"

describe Admin::SnippetController do
  scenario :users, :snippets

  integrate_views

  before :each do
    login_as :existing
  end

  it "should be an AbstractModelController" do
    controller.should be_kind_of(Admin::AbstractModelController)
  end

  it "should handle Snippets" do
    controller.class.model_class.should == Snippet
  end

  it "should require login for all actions" do
    logout
    lambda { get :index }.should require_login
    lambda { get :new }.should require_login
    lambda { get :edit }.should require_login
    lambda { get :remove }.should require_login
  end
end
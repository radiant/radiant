require File.dirname(__FILE__) + "/../../spec_helper"

describe Admin::ExtensionsController do
  dataset :users
  
  before :each do
    login_as :admin
  end
  
  it "should require login for all actions" do
    logout
    lambda { get :index }.should require_login
  end
  
  it "should list all extensions" do
    get :index
    response.should be_success
    response.should render_template("index")
    assigns[:extensions].should == Radiant::Extension.descendants.sort_by(&:name)
  end
end

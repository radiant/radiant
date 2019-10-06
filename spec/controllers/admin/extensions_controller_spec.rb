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

  describe "GET to /admin/extensions" do
    before :each do
      get :index
    end

    it "should be successful" do
      response.should be_success
    end

    it "should render the index template" do
      response.should render_template("index")
    end

    it "should list all extensions" do
      assigns[:extensions].sort_by(&:name).should == Radiant::Extension.descendants.sort_by(&:name)
    end

    it "should pre-set the template name" do
      assigns[:template_name].should == 'index'
    end
  end
end

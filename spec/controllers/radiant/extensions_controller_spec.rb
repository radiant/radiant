require "spec_helper"

describe Radiant::Admin::ExtensionsController do
  routes { Radiant::Engine.routes }
  
  test_helper :user
  include AuthenticationHelper
  
  before :each do
    login_as :admin
  end

  it "should require login for all actions" do
    logout
    expect { get :index }.to require_login
  end

  describe "GET to /admin/extensions" do
    before :each do
      get :index
    end

    it "should be successful" do
      expect(response).to be_success
    end

    it "should render the index template" do
      expect(response).to render_template("index")
    end

    it "should list all extensions" do
      expect(assigns[:extensions].sort_by(&:name)).to eq(Radiant::Extension.descendants.sort_by(&:name))
    end

    it "should pre-set the template name" do
      expect(assigns[:template_name]).to eq('index')
    end
  end
end

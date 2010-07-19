require File.dirname(__FILE__) + "/../../spec_helper"

describe Admin::PageTypesController do
  dataset :users, :home_page

  describe "index" do
    before do
      login_as :admin
      get :index, :page_id => page_id(:home)
    end

    it "should assign @page object" do
      assigns(:page).should eql(pages(:home))
    end

    it "should list page subclasses" do
      assigns(:options).should include(FileNotFoundPage)
    end
  end
end
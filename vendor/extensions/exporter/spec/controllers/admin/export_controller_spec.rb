require File.dirname(__FILE__) + "/../../spec_helper"

describe Admin::ExportController do
  dataset :users_and_pages
  
  before :each do
    login_as :designer
  end
  
  it "should export a YAML file" do
    get :yaml
    response.should be_success
    response.content_type.should == "text/yaml"
    YAML.load(response.body).should be_kind_of(Hash)
  end
end
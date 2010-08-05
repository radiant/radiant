require File.dirname(__FILE__) + '/../../spec_helper'

describe Admin::PageFieldsController do
  dataset :users

  before do
    login_as :admin
  end

  it "should assign a PageField object" do
    xhr :post, :create, :page_field => {:name => "Keywords"}
    meta = assigns(:page_field)
    meta.should be_kind_of(PageField)
    meta.name.should eql('Keywords')
  end

end

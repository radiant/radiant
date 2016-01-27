require File.dirname(__FILE__) + '/../../spec_helper'

describe Radiant::Admin::PageFieldsController do
  routes { Radiant::Engine.routes }
  #dataset :users

  before do
    login_as :admin
  end

  it "should assign a PageField object" do
    xhr :post, :create, page_field: {name: "Keywords"}
    meta = assigns(:page_field)
    expect(meta).to be_kind_of(PageField)
    expect(meta.name).to eql('Keywords')
  end

end

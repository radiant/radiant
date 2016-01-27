require File.dirname(__FILE__) + '/../../spec_helper'

describe Radiant::Admin::ReferencesController do
  routes { Radiant::Engine.routes }
  #dataset :users

  before :each do
    login_as :existing
  end

  it "should render the associated template on GET to show" do
    xhr :get, :show, type: 'tags'
    expect(response).to be_success
    expect(response).to render_template('tags')
  end
end
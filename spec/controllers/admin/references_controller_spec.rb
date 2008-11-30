require File.dirname(__FILE__) + '/../../spec_helper'

describe Admin::ReferencesController do
  scenario :users
  
  before :each do
    login_as :existing
  end
  
  it "should render the associated template on GET to show" do
    xhr :get, :show, :id => 'tags'
    response.should be_success
    response.should render_template('tags')
  end
end
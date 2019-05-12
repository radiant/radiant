require File.dirname(__FILE__) + '/../../spec_helper'

describe Admin::ReferencesController do
  dataset :users
  
  before :each do
    login_as :existing
  end
  
  it "should render the associated template on GET to show" do
    xhr :get, :show, :type => 'tags'
    response.should be_success
    response.should render_template('tags')
  end
end
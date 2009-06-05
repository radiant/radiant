require File.dirname(__FILE__) + '/../../spec_helper'

describe Admin::AssetsController do
  
  before :each do 
    @asset = Asset.make
  end

  #Delete this example and add some real ones
  it "should use Admin::AssetsController" do
    controller.should be_an_instance_of(Admin::AssetsController)
  end

end

require File.dirname(__FILE__) + "/../../spec_helper"

describe Admin::SnippetsController do
  dataset :users, :snippets

  it "should be paginated" do
    Admin::SnippetsController.paginated.should be_true
    controller.paginated?.should be_true
  end
  
  it "should have pagination defaults" do
    controller.pagination_parameters.should == {:page => 1, :per_page => 50}
    controller.will_paginate_options.should == {:param_name => :p}
  end

  it "should override defaults with pagination settings from config" do
    Radiant::Config['admin.pagination.per_page'] = 23
    controller.pagination_parameters.should == {:page => 1, :per_page => 23}
  end
  
  it "should override configuration with pagination settings from paginate_models" do
    Admin::SnippetsController.send :paginate_models, {:per_page => 5, :inner_window => 12}
    controller.pagination_parameters.should == {:page => 1, :per_page => 5}
    controller.will_paginate_options.should == {:inner_window => 12, :param_name => :p}
  end
end

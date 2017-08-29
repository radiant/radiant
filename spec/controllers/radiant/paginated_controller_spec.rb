require File.dirname(__FILE__) + "/../../spec_helper"

describe Radiant::Admin::UsersController do
  routes { Radiant::Engine.routes }

  it "should be paginated" do
    expect(Radiant::Admin::UsersController.paginated).to be true
    expect(controller.paginated?).to be true
  end

  ## I need to redo these with mock classes
  #
  # describe "with pagination settings from paginate_models" do
  #   it "should override defaults" do
  #     Radiant.detail['admin.pagination.per_page'] = ""
  #     Admin::UsersController.send :paginate_models, {per_page: 5, inner_window: 12}
  #     controller.pagination_parameters.should == {page: 1, per_page: 5}
  #     controller.will_paginate_options.should == {inner_window: 12, param_name: :p}
  #   end
  # end
  #
  # describe "with configured pagination settings" do
  #   it "should override defaults" do
  #     Radiant.detail['admin.pagination.per_page'] = 23
  #     controller.pagination_parameters.should == {page: 1, per_page: 23}
  #   end
  # end
  #
  describe "without configuration" do
    it "should have pagination defaults" do
      Radiant.detail['admin.pagination.per_page'] = nil
      expect(controller.pagination_parameters).to eq({page: 1, per_page: 50})
      expect(controller.will_paginate_options).to eq({param_name: :p})
    end
  end


end
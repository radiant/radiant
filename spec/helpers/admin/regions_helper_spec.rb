require File.dirname(__FILE__) + "/../../spec_helper"
require 'ostruct'

describe Admin::RegionsHelper do
  before :each do
    @controller = mock('controller')
    @controller.stub!(:controller_name).and_return('page')
    @first_render = "admin/page/edit"
    @admin = Radiant::AdminUI.instance
    stub!(:admin).and_return(@admin)
    @region_set_mock = Radiant::AdminUI::RegionSet.new
    @admin.stub!(:page).and_return(OpenStruct.new(:edit => @region_set_mock))
  end
  
  it "should initialize relevant region variables" do
    lazy_initialize_region_set
    @controller_name.should == 'page'
    @template_name.should == 'edit'
    @region_set.should === @region_set_mock
  end

  describe "rendering a region" do
    before :each do
      @region_set_mock.add :main, "test"
      @template = mock('template')
      @template.stub!(:capture).and_return("foo")
      lazy_initialize_region_set
    end
    
    it "should render a region with no default partials" do
      should_receive(:render).with(:partial => "test").and_return("foo")
      render_region(:main).should == "foo"
    end
    
    it "should capture the passed block, yielding the RegionPartials object and concatenating" do
      should_receive(:render).and_raise(::ActionView::ActionViewError)
      should_receive(:concat).with("foo", anything)
      @template.should_receive(:capture).and_return("foo")
      render_region(:main) do |main|
        main.should be_kind_of(Radiant::AdminUI::RegionPartials)
        main.test do
          "foo"
        end
      end
    end
  end
end
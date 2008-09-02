require File.dirname(__FILE__) + "/../../spec_helper"
require 'ostruct'

describe Admin::RegionsHelper do
  before :each do
    @controller = mock('controller')
    @controller_name = 'page'
    @controller.stub!(:controller_name).and_return(@controller_name)
    assigns[:controller_name] = @controller_name
    assigns[:first_render] = "admin/page/edit"
    @admin = Radiant::AdminUI.instance
    helper.stub!(:admin).and_return(@admin)
    @region_set_mock = Radiant::AdminUI::RegionSet.new
    @admin.stub!(:page).and_return(OpenStruct.new(:edit => @region_set_mock))
  end
  
  it "should initialize relevant region variables" do
    helper.lazy_initialize_region_set
    @controller_name == 'page'
    @template_name == 'edit'
    @region_set === @region_set_mock
  end

  describe "rendering a region" do
    before :each do
      @region_set_mock.add :main, "test"
      @template = mock('template')
      @template.stub!(:capture).and_return("foo")
      assigns[:template] = @template
      helper.lazy_initialize_region_set
    end
    
    it "should render a region with no default partials" do
      helper.should_receive(:render).with(:partial => "test").and_return("foo")
      helper.render_region(:main).should == "foo"
    end
    
    it "should capture the passed block, yielding the RegionPartials object and concatenating" do
      helper.should_receive(:render).and_raise(::ActionView::ActionViewError)
      helper.should_receive(:concat).with("foo", anything)
      @template.should_receive(:capture).and_return("foo")
      helper.render_region(:main) do |main|
        main.should be_kind_of(Radiant::AdminUI::RegionPartials)
        main.test do
          "foo"
        end
      end
    end
  end
end
require File.dirname(__FILE__) + '/spec_helper'

describe Resourceful::Default::Callbacks, " with a few callbacks" do
  include ControllerMocks
  before :each do
    mock_controller Resourceful::Default::Callbacks
    callbacks[:before] = {:create => proc { "awesome!" }}
    callbacks[:after] = {:index => proc { @var }}
    @controller.instance_variable_set('@var', 'value')
  end

  it "should fire the :before callback with the given name when #before is called" do
    @controller.before(:create).should == "awesome!"
  end

  it "should fire the :after callback with the given name when #before is called" do
    @controller.after("index").should == "value"
  end
end

describe Resourceful::Default::Callbacks, " with a few responses" do
  include ControllerMocks
  before :each do
    mock_controller Resourceful::Default::Callbacks
    responses[:create_failed] = [[:html, nil], [:js, nil]]
    responses[:create] = [[:html, proc { "create html" }], [:xml, proc { @xml }]]
    @controller.instance_variable_set('@xml', 'create XML')
    @response = Resourceful::Response.new
  end

  it "should respond to each format with a call to the given block when #response_for is called" do
    @controller.expects(:respond_to).yields(@response)
    @controller.response_for(:create_failed)
    @response.formats[0][0].should == :html
    @response.formats[0][1].call.should be_nil

    @response.formats[1][0].should == :js
    @response.formats[1][1].call.should be_nil
  end

  it "should properly scope blocks when #response_for is called" do
    @controller.expects(:respond_to).yields(@response)
    @controller.response_for(:create)
    @response.formats[0][0].should == :html
    @response.formats[0][1].call.should == "create html"

    @response.formats[1][0].should == :xml

    # This value comes from the instance variable in @controller.
    # Having it be "create XML" ensures that the block was properly scoped.
    @response.formats[1][1].call.should == "create XML"
  end
end

describe Resourceful::Default::Callbacks, "#scope" do
  include ControllerMocks
  before(:each) { mock_controller Resourceful::Default::Callbacks }

  it "should re-bind the block to the controller's context" do
    block = proc { @var }
    @controller.instance_variable_set('@var', 'value')

    block.call.should == nil
    @controller.scope(block).call.should == 'value'
  end

  it "should make the block empty if it's passed in as nil" do
    @controller.scope(nil).call.should == nil
  end
end



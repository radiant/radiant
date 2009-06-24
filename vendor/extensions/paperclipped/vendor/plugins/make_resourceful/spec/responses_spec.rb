require File.dirname(__FILE__) + '/spec_helper'

describe 'Resourceful::Default::Responses', " with a _flash parameter for :error" do
  include ControllerMocks
  before :each do
    mock_controller Resourceful::Default::Responses
    @flash = {}
    @controller.stubs(:flash).returns(@flash)
    @params = {:_flash => {:error => 'Oh no, an error!'}}
    @controller.stubs(:params).returns(@params)
  end

  it "should set the flash for :error to the parameter's value when set_default_flash is called on :error" do
    @controller.set_default_flash(:error, "Aw there's no error!")
    @flash[:error].should == 'Oh no, an error!'
  end
  
  it "should set the flash for :error to the parameter's cleansed value when set_default_flash is called on :error" do
    evil_script = "<script language=\"javascript\">alert('no good');</script>"
    @params[:_flash][:error] = evil_script
    @controller.set_default_flash(:error, "Aw there's no error!")
    @flash[:error].should == ERB::Util.h(evil_script)
  end

  it "should set the flash for :message to the default value when set_default_flash is called on :message" do
    @controller.set_default_flash(:message, "All jim dandy!")
    @flash[:message].should == 'All jim dandy!'
  end

  it "shouldn't set the flash for :error when set_default_flash is called on :message" do
    @controller.set_default_flash(:message, "All jim dandy!")
    @flash[:error].should be_nil
  end
end

describe 'Resourceful::Default::Responses', " with a _redirect parameter on :failure" do
  include ControllerMocks
  before :each do
    mock_controller Resourceful::Default::Responses
    @params = {:_redirect_on => {:failure => 'http://hamptoncatlin.com/'}}
    @controller.stubs(:params).returns(@params)
  end

  it "should set the redirect for :failure to the parameter's value when set_default_redirect is called on :failure" do
    @controller.expects(:redirect_to).with('http://hamptoncatlin.com/')
    @controller.set_default_redirect(:back, :status => :failure)
  end

  it "should set the redirect for :success to the default value when set_default_redirect is called on :success" do
    @controller.expects(:redirect_to).with(:back)
    @controller.set_default_redirect(:back, :status => :success)
  end

  it "shouldn't set the redirect for :failure when set_default_redirect is called on :success" do
    @controller.expects(:redirect_to).with(:back)
    @controller.expects(:redirect_to).with('http://hamptoncatlin.com/').never
    @controller.set_default_redirect(:back, :status => :success)
  end

  it "should set the default redirect for :success by default" do
    @controller.expects(:redirect_to).with(:back)
    @controller.set_default_redirect(:back)
  end
end

describe 'Resourceful::Default::Responses', ' for show' do
  include ControllerMocks
  before :each do
    mock_kontroller
    create_builder
    made_resourceful(Resourceful::Default::Responses)
    @builder.apply
  end

  it "should have an empty HTML response" do
    responses[:show].find { |f, p| f == :html }[1].call.should == nil
  end

  it "should have an empty JS response" do
    responses[:show].find { |f, p| f == :js }[1].call.should == nil
  end
end

describe 'Resourceful::Default::Responses', ' for index' do
  include ControllerMocks
  before :each do
    mock_kontroller
    create_builder
    made_resourceful(Resourceful::Default::Responses)
    @builder.apply
  end

  it "should have an empty HTML response" do
    responses[:index].find { |f, p| f == :html }[1].call.should == nil
  end

  it "should have an empty JS response" do
    responses[:index].find { |f, p| f == :js }[1].call.should == nil
  end
end

describe 'Resourceful::Default::Responses', ' for edit' do
  include ControllerMocks
  before :each do
    mock_kontroller
    create_builder
    made_resourceful(Resourceful::Default::Responses)
    @builder.apply
  end

  it "should have an empty HTML response" do
    responses[:edit].find { |f, p| f == :html }[1].call.should == nil
  end

  it "should have an empty JS response" do
    responses[:edit].find { |f, p| f == :js }[1].call.should == nil
  end
end

describe 'Resourceful::Default::Responses', ' for new' do
  include ControllerMocks
  before :each do
    mock_kontroller
    create_builder
    made_resourceful(Resourceful::Default::Responses)
    @builder.apply
  end

  it "should have an empty HTML response" do
    responses[:new].find { |f, p| f == :html }[1].call.should == nil
  end

  it "should have an empty JS response" do
    responses[:new].find { |f, p| f == :js }[1].call.should == nil
  end
end

describe 'Resourceful::Default::Responses', ' for show_fails' do
  include ControllerMocks
  before :each do
    mock_controller Resourceful::Default::Callbacks
    create_builder
    made_resourceful(Resourceful::Default::Responses)
    @builder.apply
  end

  it "should give a 404 error for HTML" do
    @controller.expects(:render).with(:text => "No item found", :status => 404)
    @controller.scope(responses[:show_fails].find { |f, p| f == :html }[1]).call
  end

  it "should give a 404 error for JS" do
    @controller.expects(:render).with(:text => "No item found", :status => 404)
    @controller.scope(responses[:show_fails].find { |f, p| f == :js }[1]).call
  end

  it "should give a 404 error for XML" do
    @controller.expects(:render).with(:text => "No item found", :status => 404)
    @controller.scope(responses[:show_fails].find { |f, p| f == :xml }[1]).call
  end
end

describe 'Resourceful::Default::Responses', ' for create' do
  include ControllerMocks
  before :each do
    mock_controller Resourceful::Default::Callbacks
    create_builder
    made_resourceful(Resourceful::Default::Responses)
    @builder.apply

    [:set_default_flash, :set_default_redirect, :object_path].each(&@controller.method(:stubs))
  end

  it "should have an empty JS response" do
    responses[:create].find { |f, p| f == :js }[1].call.should == nil
  end

  it "should flash a success message to :notice by default for HTML" do
    @controller.expects(:set_default_flash).with(:notice, "Create successful!")
    @controller.scope(responses[:create].find { |f, p| f == :html }[1]).call
  end

  it "should redirect to object_path by default for HTML" do
    @controller.stubs(:object_path).returns("/posts/12")
    @controller.expects(:set_default_redirect).with("/posts/12")
    @controller.scope(responses[:create].find { |f, p| f == :html }[1]).call
  end
end

describe 'Resourceful::Default::Responses', ' for create_fails' do
  include ControllerMocks
  before :each do
    mock_controller Resourceful::Default::Callbacks
    create_builder
    made_resourceful(Resourceful::Default::Responses)
    @builder.apply

    [:set_default_flash, :render].each(&@controller.method(:stubs))
  end

  it "should have an empty JS response" do
    responses[:create_fails].find { |f, p| f == :js }[1].call.should == nil
  end

  it "should flash a failure message to :error by default for HTML" do
    @controller.expects(:set_default_flash).with(:error, "There was a problem!")
    @controller.scope(responses[:create_fails].find { |f, p| f == :html }[1]).call
  end

  it "should render new with a 422 error for HTML" do
    @controller.expects(:render).with(:action => :new, :status => 422)
    @controller.scope(responses[:create_fails].find { |f, p| f == :html }[1]).call
  end
end

describe 'Resourceful::Default::Responses', ' for update' do
  include ControllerMocks
  before :each do
    mock_controller Resourceful::Default::Callbacks
    create_builder
    made_resourceful(Resourceful::Default::Responses)
    @builder.apply

    [:set_default_flash, :set_default_redirect, :object_path].each(&@controller.method(:stubs))
  end

  it "should have an empty JS response" do
    responses[:update].find { |f, p| f == :js }[1].call.should == nil
  end

  it "should flash a success message to :notice by default for HTML" do
    @controller.expects(:set_default_flash).with(:notice, "Save successful!")
    @controller.scope(responses[:update].find { |f, p| f == :html }[1]).call
  end

  it "should redirect to object_path by default for HTML" do
    @controller.stubs(:object_path).returns("/posts/12")
    @controller.expects(:set_default_redirect).with("/posts/12")
    @controller.scope(responses[:update].find { |f, p| f == :html }[1]).call
  end
end

describe 'Resourceful::Default::Responses', ' for update_fails' do
  include ControllerMocks
  before :each do
    mock_controller Resourceful::Default::Callbacks
    create_builder
    made_resourceful(Resourceful::Default::Responses)
    @builder.apply

    [:set_default_flash, :render].each(&@controller.method(:stubs))
  end

  it "should have an empty JS response" do
    responses[:update_fails].find { |f, p| f == :js }[1].call.should == nil
  end

  it "should flash a failure message to :error by default for HTML" do
    @controller.expects(:set_default_flash).with(:error, "There was a problem saving!")
    @controller.scope(responses[:update_fails].find { |f, p| f == :html }[1]).call
  end

  it "should render edit with a 422 error for HTML" do
    @controller.expects(:render).with(:action => :edit, :status => 422)
    @controller.scope(responses[:update_fails].find { |f, p| f == :html }[1]).call
  end
end


describe 'Resourceful::Default::Responses', ' for destroy' do
  include ControllerMocks
  before :each do
    mock_controller Resourceful::Default::Callbacks
    create_builder
    made_resourceful(Resourceful::Default::Responses)
    @builder.apply

    [:set_default_flash, :set_default_redirect, :objects_path].each(&@controller.method(:stubs))
  end

  it "should have an empty JS response" do
    responses[:destroy].find { |f, p| f == :js }[1].call.should == nil
  end

  it "should flash a success message to :notice by default for HTML" do
    @controller.expects(:set_default_flash).with(:notice, "Record deleted!")
    @controller.scope(responses[:destroy].find { |f, p| f == :html }[1]).call
  end

  it "should redirect to objects_path by default for HTML" do
    @controller.stubs(:objects_path).returns("/posts")
    @controller.expects(:set_default_redirect).with("/posts")
    @controller.scope(responses[:destroy].find { |f, p| f == :html }[1]).call
  end
end

describe 'Resourceful::Default::Responses', ' for destroy_fails' do
  include ControllerMocks
  before :each do
    mock_controller Resourceful::Default::Callbacks
    create_builder
    made_resourceful(Resourceful::Default::Responses)
    @builder.apply

    [:set_default_flash, :set_default_redirect, :render].each(&@controller.method(:stubs))
  end

  it "should have an empty JS response" do
    responses[:destroy_fails].find { |f, p| f == :js }[1].call.should == nil
  end

  it "should flash a failure message to :error by default for HTML" do
    @controller.expects(:set_default_flash).with(:error, "There was a problem deleting!")
    @controller.scope(responses[:destroy_fails].find { |f, p| f == :html }[1]).call
  end

  it "should redirect back on failure by default for HTML" do
    @controller.expects(:set_default_redirect).with(:back, :status => :failure)
    @controller.scope(responses[:destroy_fails].find { |f, p| f == :html }[1]).call
  end
end

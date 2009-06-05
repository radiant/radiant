require File.dirname(__FILE__) + '/spec_helper'

describe Resourceful::Default::Actions, " index action" do
  include ControllerMocks
  before :each do
    mock_controller Resourceful::Default::Actions
    [:load_objects, :before, :response_for].each(&@controller.method(:stubs))
  end

  after(:each) { @controller.index }

  it "should load the object collection" do
    @controller.expects(:load_objects)
  end

  it "should call the before :index callback" do
    @controller.expects(:before).with(:index)
  end

  it "should run the response for index" do
    @controller.expects(:response_for).with(:index)
  end
end

describe Resourceful::Default::Actions, " show action" do
  include ControllerMocks
  before :each do
    mock_controller Resourceful::Default::Actions
    [:load_object, :before, :response_for].each(&@controller.method(:stubs))
  end

  after(:each) { @controller.show }
  
  it "should load the instance object" do
    @controller.expects(:load_object)
  end

  it "should call the before :show callback" do
    @controller.expects(:before).with(:show)
  end

  it "should run the response for show" do
    @controller.expects(:response_for).with(:show)
  end

  it "should run the response for show failing if an exception is raised" do
    @controller.stubs(:load_object).raises("Oh no!")
    @controller.expects(:response_for).with(:show_fails)
  end
end

describe Resourceful::Default::Actions, " successful create action" do
  include ControllerMocks
  before :each do
    mock_controller Resourceful::Default::Actions
    [:build_object, :load_object, :before, :after,
     :save_succeeded!, :response_for].each(&@controller.method(:stubs))
    @object = stub :save => true
    @controller.stubs(:current_object).returns(@object)
  end

  after(:each) { @controller.create }

  it "should build the object from the POSTed parameters" do
    @controller.expects(:build_object)
  end

  it "should load the instance object" do
    @controller.expects(:load_object)
  end

  it "should call the before :create callback" do
    @controller.expects(:before).with(:create)
  end

  it "should try to save the object" do
    @object.expects(:save).returns(true)
  end

  it "should record the successful save" do
    @controller.expects(:save_succeeded!)
  end

  it "should call the after :create callback" do
    @controller.expects(:after).with(:create)
  end

  it "should run the response for create" do
    @controller.expects(:response_for).with(:create)
  end
end

describe Resourceful::Default::Actions, " unsuccessful create action" do
  include ControllerMocks
  before :each do
    mock_controller Resourceful::Default::Actions
    [:build_object, :load_object, :before, :after,
     :save_failed!, :response_for].each(&@controller.method(:stubs))
    @object = stub :save => false
    @controller.stubs(:current_object).returns(@object)
  end

  after(:each) { @controller.create }

  it "should record the unsuccessful save" do
    @controller.expects(:save_failed!)
  end

  it "should call the after :create_fails callback" do
    @controller.expects(:after).with(:create_fails)
  end

  it "should run the response for create failing" do
    @controller.expects(:response_for).with(:create_fails)
  end
end

describe Resourceful::Default::Actions, " successful update action" do
  include ControllerMocks
  before :each do
    mock_controller Resourceful::Default::Actions
    [:load_object, :before, :after, :object_parameters,
     :save_succeeded!, :response_for].each(&@controller.method(:stubs))
    @object = stub :update_attributes => true
    @controller.stubs(:current_object).returns(@object)
  end

  after(:each) { @controller.update }

  it "should load the instance object" do
    @controller.expects(:load_object)
  end

  it "should call the before :update callback" do
    @controller.expects(:before).with(:update)
  end

  it "should try to update the object with the POSTed attributes" do
    @controller.expects(:object_parameters).returns(:params => "stuff")
    @object.expects(:update_attributes).with(:params => "stuff").returns(true)
  end

  it "should record the successful save" do
    @controller.expects(:save_succeeded!)
  end

  it "should call the after :update callback" do
    @controller.expects(:after).with(:update)
  end

  it "should run the response for update" do
    @controller.expects(:response_for).with(:update)
  end
end

describe Resourceful::Default::Actions, " unsuccessful update action" do
  include ControllerMocks
  before :each do
    mock_controller Resourceful::Default::Actions
    [:load_object, :before, :after, :object_parameters,
     :save_failed!, :response_for].each(&@controller.method(:stubs))
    @object = stub :update_attributes => false
    @controller.stubs(:current_object).returns(@object)
  end

  after(:each) { @controller.update }

  it "should record the unsuccessful save" do
    @controller.expects(:save_failed!)
  end

  it "should call the after :update_fails callback" do
    @controller.expects(:after).with(:update_fails)
  end

  it "should run the response for update failing" do
    @controller.expects(:response_for).with(:update_fails)
  end
end

describe Resourceful::Default::Actions, " new action" do
  include ControllerMocks
  before :each do
    mock_controller Resourceful::Default::Actions
    [:build_object, :load_object,
     :before, :response_for].each(&@controller.method(:stubs))
  end

  after(:each) { @controller.new }

  it "should build the object from the POSTed parameters" do
    @controller.expects(:build_object)
  end

  it "should load the instance object" do
    @controller.expects(:load_object)
  end

  it "should call the before :new callback" do
    @controller.expects(:before).with(:new)
  end

  it "should run the response for new" do
    @controller.expects(:response_for).with(:new)
  end
end

describe Resourceful::Default::Actions, " edit action" do
  include ControllerMocks
  before :each do
    mock_controller Resourceful::Default::Actions
    [:load_object, :before, :response_for].each(&@controller.method(:stubs))
  end

  after(:each) { @controller.edit }

  it "should load the instance object" do
    @controller.expects(:load_object)
  end

  it "should call the before :edit callback" do
    @controller.expects(:before).with(:edit)
  end

  it "should run the response for edit" do
    @controller.expects(:response_for).with(:edit)
  end
end

describe Resourceful::Default::Actions, " successful destroy action" do
  include ControllerMocks
  before :each do
    mock_controller Resourceful::Default::Actions
    [:load_object, :before,
     :after, :response_for].each(&@controller.method(:stubs))
    @object = stub :destroy => true
    @controller.stubs(:current_object).returns(@object)
  end

  after(:each) { @controller.destroy }

  it "should load the instance object" do
    @controller.expects(:load_object)
  end

  it "should call the before :destroy callback" do
    @controller.expects(:before).with(:destroy)
  end

  it "should try to destroy the object" do
    @object.expects(:destroy).returns(true)
  end

  it "should call the after :destroy callback" do
    @controller.expects(:after).with(:destroy)
  end

  it "should run the response for destroy" do
    @controller.expects(:response_for).with(:destroy)
  end
end

describe Resourceful::Default::Actions, " unsuccessful destroy action" do
  include ControllerMocks
  before :each do
    mock_controller Resourceful::Default::Actions
    [:load_object, :before,
     :after, :response_for].each(&@controller.method(:stubs))
    @object = stub :destroy => false
    @controller.stubs(:current_object).returns(@object)
  end

  after(:each) { @controller.destroy }

  it "should call the after :destroy_fails callback" do
    @controller.expects(:after).with(:destroy_fails)
  end

  it "should run the response for destroy failing" do
    @controller.expects(:response_for).with(:destroy_fails)
  end
end


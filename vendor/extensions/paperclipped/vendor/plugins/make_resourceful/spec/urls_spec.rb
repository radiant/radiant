require File.dirname(__FILE__) + '/spec_helper'

describe Resourceful::Default::URLs, " for a controller with no parents or namespaces" do
  include ControllerMocks
  before :each do
    mock_controller Resourceful::Default::URLs
    @object = stub_model('Thing')
    @controller.stubs(:current_object).returns(@object)
    
    @controller.stubs(:current_model_name).returns('Thing')
    @controller.stubs(:parent?).returns(false)
    @controller.stubs(:namespaces).returns([])
  end

  it "should return nil for #url_helper_prefix" do
    @controller.url_helper_prefix.should be_nil
  end

  it "should return the empty string for #collection_url_prefix" do
    @controller.collection_url_prefix.should == ""
  end

  it "should get the path of current_object with #object_path" do
    @controller.expects(:send).with('thing_path', @object)
    @controller.object_path
  end

  it "should get the url of current_object with #object_url" do
    @controller.expects(:send).with('thing_url', @object)
    @controller.object_url
  end

  it "should get the path of the passed object with #object_path" do
    model = stub_model('Thing')
    @controller.expects(:send).with('thing_path', model)
    @controller.object_path(model)
  end

  it "should get the url of the passed object with #object_url" do
    model = stub_model('Thing')
    @controller.expects(:send).with('thing_url', model)
    @controller.object_url(model)
  end

  it "should get the path of current_object with #nested_object_path" do
    @controller.expects(:send).with('thing_path', @object)
    @controller.nested_object_path
  end

  it "should get the url of current_object with #nested_object_url" do
    @controller.expects(:send).with('thing_url', @object)
    @controller.nested_object_url
  end

  it "should get the path of the passed object with #nested_object_path" do
    model = stub_model('Thing')
    @controller.expects(:send).with('thing_path', model)
    @controller.nested_object_path(model)
  end

  it "should get the url of the passed object with #nested_object_url" do
    model = stub_model('Thing')
    @controller.expects(:send).with('thing_url', model)
    @controller.nested_object_url(model)
  end

  it "should get the edit path of current_object with #edit_object_path" do
    @controller.expects(:send).with('edit_thing_path', @object)
    @controller.edit_object_path
  end

  it "should get the edit url of current_object with #edit_object_url" do
    @controller.expects(:send).with('edit_thing_url', @object)
    @controller.edit_object_url
  end

  it "should get the edit path of the passed object with #edit_object_path" do
    model = stub_model('Thing')
    @controller.expects(:send).with('edit_thing_path', model)
    @controller.edit_object_path(model)
  end

  it "should get the edit url of the passed object with #edit_object_url" do
    model = stub_model('Thing')
    @controller.expects(:send).with('edit_thing_url', model)
    @controller.edit_object_url(model)
  end

  it "should get the plural path of the current model with #objects_path" do
    @controller.expects(:send).with('things_path')
    @controller.objects_path
  end

  it "should get the plural url of the current model with #objects_url" do
    @controller.expects(:send).with('things_url')
    @controller.objects_url
  end

  it "should get the new path of the current model with #new_object_path" do
    @controller.expects(:send).with('new_thing_path')
    @controller.new_object_path
  end

  it "should get the new url of the current model with #new_object_url" do
    @controller.expects(:send).with('new_thing_url')
    @controller.new_object_url
  end
end

describe Resourceful::Default::URLs, " for a controller with a parent object" do
  include ControllerMocks
  before :each do
    mock_controller Resourceful::Default::URLs
    @object = stub_model('Thing')
    @controller.stubs(:current_object).returns(@object)
    
    @controller.stubs(:current_model_name).returns('Thing')

    @person = stub_model('Person')
    @controller.stubs(:parent_object).returns(@person)
    @controller.stubs(:parent_name).returns('person')
    @controller.stubs(:parent?).returns(true)
    @controller.stubs(:namespaces).returns([])
  end

  it "should return nil for #url_helper_prefix" do
    @controller.url_helper_prefix.should be_nil
  end

  it "should return the underscored parent name for #collection_url_prefix" do
    @controller.collection_url_prefix.should == "person_"
  end

  it "should get the path of current_object with #object_path" do
    @controller.expects(:send).with('thing_path', @object)
    @controller.object_path
  end

  it "should get the nested path of current_object with #nested_object_path" do
    @controller.expects(:send).with('person_thing_path', @person, @object)
    @controller.nested_object_path
  end

  it "should get the nested url of current_object with #nested_object_url" do
    @controller.expects(:send).with('person_thing_url', @person, @object)
    @controller.nested_object_url
  end

  it "should get the nested path of the passed object with #nested_object_path" do
    object = stub_model('Thing')
    @controller.expects(:send).with('person_thing_path', @person, object)
    @controller.nested_object_path object
  end

  it "should get the nested url of the passed object with #nested_object_url" do
    object = stub_model('Thing')
    @controller.expects(:send).with('person_thing_url', @person, object)
    @controller.nested_object_url object
  end

  it "should get the plural path of the current model and its parent with #objects_path" do
    @controller.expects(:send).with('person_things_path', @person)
    @controller.objects_path
  end

  it "should get the edit path of the current model with #edit_object_path" do
    @controller.expects(:send).with('edit_thing_path', @object)
    @controller.edit_object_path
  end

  it "should get the new path of the current model and its parent with #new_object_path" do
    @controller.expects(:send).with('new_person_thing_path', @person)
    @controller.new_object_path
  end

  it "should get the path of the parent_object with #parent_path" do
    @controller.expects(:send).with('person_path', @person)
    @controller.parent_path
  end

  it "should get the url of the parent_object with #parent_url" do
    @controller.expects(:send).with('person_url', @person)
    @controller.parent_url
  end

  it "should get the path of the passed object with #parent_path" do
    model = stub_model('Person')
    @controller.expects(:send).with('person_path', model)
    @controller.parent_path model
  end

  it "should get the url of the passed object with #parent_url" do
    model = stub_model('Person')
    @controller.expects(:send).with('person_url', model)
    @controller.parent_url model
  end
end

describe Resourceful::Default::URLs, " for a controller within a namespace" do
  include ControllerMocks
  before :each do
    mock_controller Resourceful::Default::URLs
    @object = stub_model('Thing')
    @controller.stubs(:current_object).returns(@object)
    
    @controller.stubs(:current_model_name).returns('Thing')

    @controller.stubs(:parent?).returns(false)
    @controller.stubs(:namespaces).returns([:admin, :main])
  end

  it "should return the underscored list of namespaces for #url_helper_prefix" do
    @controller.url_helper_prefix.should == "admin_main_"
  end

  it "should get the namespaced path of current_object with #object_path" do
    @controller.expects(:send).with('admin_main_thing_path', @object)
    @controller.object_path
  end

  it "should get the namespaced plural path of the current model with #objects_path" do
    @controller.expects(:send).with('admin_main_things_path')
    @controller.objects_path
  end

  it "should get the edit path of the current model with #edit_object_path" do
    @controller.expects(:send).with('edit_admin_main_thing_path', @object)
    @controller.edit_object_path
  end

  it "should get the new path of the current model with #new_object_path" do
    @controller.expects(:send).with('new_admin_main_thing_path')
    @controller.new_object_path
  end
end

describe Resourceful::Default::URLs, " for a controller with a parent object and within a namespace" do
  include ControllerMocks
  before :each do
    mock_controller Resourceful::Default::URLs
    @object = stub_model('Thing')
    @controller.stubs(:current_object).returns(@object)
    
    @controller.stubs(:current_model_name).returns('Thing')

    @person = stub_model('Person')
    @controller.stubs(:parent_object).returns(@person)
    @controller.stubs(:parent_name).returns('person')
    @controller.stubs(:parent?).returns(true)
    @controller.stubs(:namespaces).returns([:admin, :main])
  end

  it "should return the underscored list of namespaces for #url_helper_prefix" do
    @controller.url_helper_prefix.should == "admin_main_"
  end

  it "should get the namespaced path of current_object with #object_path" do
    @controller.expects(:send).with('admin_main_thing_path', @object)
    @controller.object_path
  end

  it "should get the namespaced plural path of the current model and its parent with #objects_path" do
    @controller.expects(:send).with('admin_main_things_path', @person)
    @controller.objects_path
  end

  it "should get the edit path of the current model with #edit_object_path" do
    @controller.expects(:send).with('edit_admin_main_thing_path', @object)
    @controller.edit_object_path
  end

  it "should get the new path of the current model and its parent with #new_object_path" do
    @controller.expects(:send).with('new_admin_main_thing_path', @person)
    @controller.new_object_path
  end
end

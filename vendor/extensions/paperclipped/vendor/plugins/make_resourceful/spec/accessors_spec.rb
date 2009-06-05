require File.dirname(__FILE__) + '/spec_helper'

describe Resourceful::Default::Accessors, "#current_objects" do
  include ControllerMocks
  before :each do
    mock_controller Resourceful::Default::Accessors
    @objects = stub_list 5, 'object'
    @model = stub
    @controller.stubs(:current_model).returns(@model)
  end

  it "should look up all objects in the current model" do
    @model.expects(:find).with(:all).returns(@objects)
    @controller.current_objects.should == @objects
  end

  it "should cache the result, so subsequent calls won't run multiple queries" do
    @model.expects(:find).once.returns(@objects)
    @controller.current_objects
    @controller.current_objects
  end

  it "shouldn't run a query if @current_objects is set" do
    @controller.instance_variable_set('@current_objects', @objects)
    @model.expects(:find).never
    @controller.current_objects.should == @objects
  end
end

describe Resourceful::Default::Accessors, "#load_objects" do
  include ControllerMocks
  before :each do
    mock_controller Resourceful::Default::Accessors
    @objects = stub_list 5, 'object'
    @controller.stubs(:current_objects).returns(@objects)
    @controller.stubs(:instance_variable_name).returns("posts")
  end

  it "should set the current instance variable to the object collection" do
    @controller.load_objects
    @controller.instance_variable_get('@posts').should == @objects
  end
end

describe Resourceful::Default::Accessors, "#current_object on a plural controller" do
  include ControllerMocks
  before :each do
    mock_controller Resourceful::Default::Accessors
    @controller.stubs(:plural?).returns(true)
    @controller.stubs(:params).returns(:id => "12")

    @object = stub
    @model = stub
    @controller.stubs(:current_model).returns(@model)
  end

  it "should look up the object specified by the :id parameter in the current model" do
    @model.expects(:find).with('12').returns(@object)
    @controller.current_object.should == @object
  end

  it "should cache the result, so subsequent calls won't run multiple queries" do
    @model.expects(:find).once.returns(@object)
    @controller.current_object
    @controller.current_object
  end

  it "shouldn't run a query if @current_object is set" do
    @controller.instance_variable_set('@current_object', @object)
    @model.expects(:find).never
    @controller.current_object.should == @object
  end
end

describe Resourceful::Default::Accessors, "#current_object on a singular controller" do
  include ControllerMocks
  before :each do
    mock_controller Resourceful::Default::Accessors
    @controller.stubs(:plural?).returns(false)
    @controller.stubs(:instance_variable_name).returns("post")

    @parent = stub('parent')
    @controller.stubs(:parent_object).returns(@parent)
    @controller.stubs(:parent?).returns(true)

    @object = stub
  end

  it "should look up the instance object of the parent object" do
    @parent.expects(:post).returns(@object)
    @controller.current_object.should == @object
  end
end

describe Resourceful::Default::Accessors, "#load_object" do
  include ControllerMocks
  before :each do
    mock_controller Resourceful::Default::Accessors
    @object = stub
    @controller.stubs(:current_object).returns(@object)
    @controller.stubs(:instance_variable_name).returns("posts")
  end

  it "should set the current singular instance variable to the current object" do
    @controller.load_object
    @controller.instance_variable_get('@post').should == @object
  end
end

describe Resourceful::Default::Accessors, "#build_object with a #build-able model" do
  include ControllerMocks
  before :each do
    mock_controller Resourceful::Default::Accessors
    @params = {:name => "Bob", :password => "hideously insecure"}
    @controller.stubs(:object_parameters).returns(@params)

    @object = stub
    @model = stub
    @controller.stubs(:current_model).returns(@model)

    @model.stubs(:build).returns(@object)
  end

  it "should return a new object built with current_model from the object parameters" do
    @model.expects(:build).with(@params).returns(@object)
    @controller.build_object.should == @object
  end

  it "should make current_object return the newly built object" do
    @controller.build_object
    @controller.current_object.should == @object
  end
end

describe Resourceful::Default::Accessors, "#build_object with a non-#build-able model" do
  include ControllerMocks
  before :each do
    mock_controller Resourceful::Default::Accessors
    @params = {:name => "Bob", :password => "hideously insecure"}
    @controller.stubs(:object_parameters).returns(@params)

    @controller.stubs(:singular?).returns(false)
    @controller.stubs(:parent?).returns(false)

    @object = stub
    @model = stub
    @controller.stubs(:current_model).returns(@model)

    @model.stubs(:new).returns(@object)
  end

  it "should return a new instance of the current_model built with the object parameters" do
    @model.expects(:new).with(@params).returns(@object)
    @controller.build_object.should == @object
  end
end

describe Resourceful::Default::Accessors, "#current_model_name" do
  include ControllerMocks
  before :each do
    mock_controller Resourceful::Default::Accessors
    @controller.stubs(:controller_name).returns("funky_posts")
  end

  it "should return the controller's name, singularized and camel-cased" do
    @controller.current_model_name.should == "FunkyPost"
  end
end

describe Resourceful::Default::Accessors, "#namespaces" do
  include ControllerMocks
  before :each do
    mock_controller Resourceful::Default::Accessors
    @kontroller.stubs(:name).returns("FunkyStuff::Admin::Posts")
  end

  it "should return an array of underscored symbols representing the namespaces of the controller class" do
    @controller.namespaces.should == [:funky_stuff, :admin]
  end

  it "should cache the result, so subsequent calls won't run multiple computations" do
    @kontroller.expects(:name).once.returns("Posts")
    @controller.namespaces
    @controller.namespaces
  end
end

describe Resourceful::Default::Accessors, "#instance_variable_name" do
  include ControllerMocks
  before :each do
    mock_controller Resourceful::Default::Accessors
    @controller.stubs(:controller_name).returns("posts")
  end
  
  it "should return controller_name" do
    @controller.instance_variable_name == "posts"
  end
end

describe Resourceful::Default::Accessors, "#current_model for a singular controller" do
  include ControllerMocks
  before :each do
    mock_controller Resourceful::Default::Accessors
    stub_const :Post
    @controller.stubs(:singular?).returns(true)
    @controller.stubs(:current_model_name).returns("Post")

    @parent = stub('parent')
    @controller.stubs(:parent_object).returns(@parent)
    @controller.stubs(:parent?).returns(true)
  end
  
  it "should return the constant named by current_model_name" do
    @controller.current_model.should == Post
  end
end

describe Resourceful::Default::Accessors, "#current_model for a plural controller with no parent" do
  include ControllerMocks
  before :each do
    mock_controller Resourceful::Default::Accessors
    stub_const :Post
    @controller.stubs(:singular?).returns(false)
    @controller.stubs(:current_model_name).returns("Post")
    @controller.stubs(:parent?).returns(false)
  end
  
  it "should return the constant named by current_model_name" do
    @controller.current_model.should == Post
  end
end

describe Resourceful::Default::Accessors, "#object_parameters" do
  include ControllerMocks
  before :each do
    mock_controller Resourceful::Default::Accessors
    @params = {"crazy_user" => {:name => "Hampton", :location => "Canada"}}
    @controller.stubs(:params).returns(@params)
    @controller.stubs(:current_model_name).returns("CrazyUser")
  end

  it "should return the element of the params hash with the name of the model" do
    @controller.object_parameters.should == @params["crazy_user"]
  end
end

describe Resourceful::Default::Accessors, " with two parent classes set on the controller class and one parent parameter supplied" do
  include ControllerMocks
  before :each do
    mock_controller Resourceful::Default::Accessors
    @parents = %w{post comment}
    @models = @parents.map(&:camelize).map(&method(:stub_const))
    @kontroller.write_inheritable_attribute(:parents, @parents)
    @controller.stubs(:singular?).returns(false)
    @controller.stubs(:instance_variable_name).returns('lines')

    @params = HashWithIndifferentAccess.new :post_id => 12
    @controller.stubs(:params).returns(@params)

    @post = stub('Post')
    Post.stubs(:find).returns(@post)

    @model = stub
  end

  it "should return true for #parent?" do
    @controller.parent?.should be_true
  end

  it "should return the string names of all the parents for #parent_names" do
    @controller.parent_names.should == @parents
  end

  it "should return the string name of the current parent for #parent_name" do
    @controller.parent_name.should == 'post'
  end

  it "should return the model class for #parent_model" do
    @controller.parent_model.should == Post
  end

  it "should return the parent object for #parent_object" do
    Post.expects(:find).with(12).returns(@post)
    @controller.parent_object.should == @post
  end

  it "should cache the value of #parent_object so multiple calls won't cause multiple queries" do
    Post.expects(:find).returns(@post).once
    @controller.parent_object
    @controller.parent_object
  end

  it "should bind the parent object its proper instance variable" do
    @controller.load_parent_object
    @controller.instance_variable_get('@post').should == @post
  end

  it "should return the parent-scoped model for #current_model" do
    @post.stubs(:lines).returns(@model)
    @controller.current_model.should == @model
  end

  it "should return true for #ensure_parent_exists" do
    @controller.expects(:render).never
    @controller.ensure_parent_exists.should be_true
  end
end

describe Resourceful::Default::Accessors, " with two parent classes set on the controller class but no parent parameter supplied" do
  include ControllerMocks
  before :each do
    mock_controller Resourceful::Default::Accessors
    @parents = %w{post comment}
    @models = @parents.map(&:camelize).map(&method(:stub_const))
    @kontroller.write_inheritable_attribute(:parents, @parents)
    @controller.stubs(:params).returns({})
    @controller.stubs(:controller_name).returns('line')
    stub_const('Line')
  end

  it "should return false for #parent?" do
    @controller.parent?.should be_false
  end

  it "should return nil for #parent_name" do
    @controller.parent_name.should be_nil
  end

  it "should return the unscoped model for #current_model" do
    @controller.current_model.should == Line
  end

  it "should return false and render a 422 error for #ensure_parent_exists" do
    @controller.expects(:render).with(has_entry(:status, 422))
    @controller.ensure_parent_exists.should be_false
  end
end

describe Resourceful::Default::Accessors, " with no parents" do
  include ControllerMocks
  before :each do
    mock_controller Resourceful::Default::Accessors
    @controller.stubs(:parents).returns([])
    @controller.stubs(:current_model_name).returns('Line')
    stub_const 'Line'
  end

  it "should return false for #parent?" do
    @controller.parent?.should be_false
  end

  it "should return nil for #parent_name" do
    @controller.parent_name.should be_nil
  end

  it "should return the unscoped model for #current_model" do
    @controller.current_model.should == Line
  end
end

describe Resourceful::Default::Accessors, " for a singular controller with a parent" do
  include ControllerMocks
  before :each do
    mock_controller Resourceful::Default::Accessors
    @controller.stubs(:singular?).returns(true)
    
    @model = stub_model('Thing')    
    @model.send(:attr_accessor, :person_id)
    @controller.stubs(:current_model).returns(@model)

    @person = stub_model('Person')
    @person.stubs(:id).returns 42
    @controller.stubs(:parent_object).returns(@person)
    @controller.stubs(:parent_name).returns('person')
    @controller.stubs(:parent?).returns(true)

    @controller.stubs(:object_parameters).returns :thinginess => 12, :bacon => true
  end

  it "should set assign the parent's id to a newly built object" do
    thing = @controller.build_object
    thing.thinginess.should == 12
    thing.person_id.should == @person.id
  end
end

describe Resourceful::Default::Accessors, "#save_succeeded!" do
  include ControllerMocks
  before :each do
    mock_controller Resourceful::Default::Accessors
    @controller.save_succeeded!
  end

  it "should make #save_succeeded? return true" do
    @controller.save_succeeded?.should be_true
  end
end

describe Resourceful::Default::Accessors, "#save_failed!" do
  include ControllerMocks
  before :each do
    mock_controller Resourceful::Default::Accessors
    @controller.save_failed!
  end

  it "should make #save_succeeded? return false" do
    @controller.save_succeeded?.should be_false
  end
end

describe Resourceful::Default::Accessors, " for a plural action" do
  include ControllerMocks
  before :each do
    mock_controller Resourceful::Default::Accessors
    @controller.stubs(:params).returns :action => "index"
  end

  it "should know it's a plural action" do
    @controller.should be_a_plural_action
  end

  it "should know it's not a singular action" do
    @controller.should_not be_a_singular_action
  end
end

describe Resourceful::Default::Accessors, " for a singular action" do
  include ControllerMocks
  before :each do
    mock_controller Resourceful::Default::Accessors
    @controller.stubs(:params).returns :action => "show"
  end

  it "should know it's not a plural action" do
    @controller.should_not be_a_plural_action
  end

  it "should know it's a singular action" do
    @controller.should be_a_singular_action
  end
end

describe Resourceful::Default::Accessors, " for a singular controller" do
  include ControllerMocks
  before :each do
    mock_controller Resourceful::Default::Accessors
    @controller.stubs(:instance_variable_name).returns "post"
  end

  it "should know it's not plural" do
    @controller.should_not be_plural
  end

  it "should know it's singular" do
    @controller.should be_singular
  end
end

describe Resourceful::Default::Accessors, " for a plural controller" do
  include ControllerMocks
  before :each do
    mock_controller Resourceful::Default::Accessors
    @controller.stubs(:instance_variable_name).returns "posts"
  end

  it "should know it's plural" do
    @controller.should be_plural
  end

  it "should know it's not singular" do
    @controller.should_not be_singular
  end
end

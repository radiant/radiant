require File.dirname(__FILE__) + '/spec_helper'

describe "ThingsController", "with all the resourceful actions", :type => :integration do
  include RailsMocks
  #inherit Test::Unit::TestCase
  before :each do
    mock_resourceful do
      actions :all
    end
    @objects = stub_list(5, 'Thing') do |t|
      [:destroy, :save, :update_attributes].each { |m| t.stubs(m).returns(true) }
      t.stubs(:to_param).returns('12')
    end
    @object = @objects.first
    Thing.stubs(:find).returns(@object)
    Thing.stubs(:new).returns(@object)
  end

  ## Default responses

  (Resourceful::ACTIONS - Resourceful::MODIFYING_ACTIONS).each(&method(:should_render_html))
  Resourceful::ACTIONS.each(&method(:should_render_js))
  Resourceful::ACTIONS.each(&method(:shouldnt_render_xml))

  ## Specs for #index

  it "should find all records on GET /things" do
    Thing.expects(:find).with(:all).returns(@objects)
    get :index
  end

  it "should return a list of objects for #current_objects after GET /things" do
    Thing.stubs(:find).returns(@objects)
    get :index
    controller.current_objects.should == @objects
  end

  it "should assign @things to a list of objects for GET /things" do
    Thing.stubs(:find).returns(@objects)
    get :index
    assigns(:things).should == @objects
  end

  ## Specs for #show

  it "should find the record with id 12 on GET /things/12" do
    Thing.expects(:find).with('12').returns(@object)
    get :show, :id => 12
  end

  it "should return an object for #current_object after GET /things/12" do
    Thing.stubs(:find).returns(@object)
    get :show, :id => 12
    controller.current_object.should == @object
  end

  it "should assign @thing to an object for GET /things/12" do
    Thing.stubs(:find).returns(@object)
    get :show, :id => 12
    assigns(:thing).should == @object
  end  

  ## Specs for #edit

  it "should find the record with id 12 on GET /things/12/edit" do
    Thing.expects(:find).with('12').returns(@object)
    get :edit, :id => 12
  end

  it "should return an object for #current_object after GET /things/12/edit" do
    Thing.stubs(:find).returns(@object)
    get :edit, :id => 12
    controller.current_object.should == @object
  end

  it "should assign @thing to an object for GET /things/12/edit" do
    Thing.stubs(:find).returns(@object)
    get :edit, :id => 12
    assigns(:thing).should == @object
  end

  ## Specs for #new

  it "should create a new object from params[:thing] for GET /things/new" do
    Thing.expects(:new).with('name' => "Herbert the thing").returns(@object)
    get :new, :thing => {:name => "Herbert the thing"}
  end

  it "should create a new object even if there aren't any params for GET /things/new" do
    Thing.expects(:new).with(nil).returns(@object)
    get :new
  end

  it "should return the new object for #current_object after GET /things/new" do
    Thing.stubs(:new).returns(@object)
    get :new
    controller.current_object.should == @object
  end

  it "should assign @thing to the new object for GET /things/new" do
    Thing.stubs(:new).returns(@object)
    get :new
    assigns(:thing).should == @object
  end

  ## Specs for #create

  it "should create a new object from params[:thing] for POST /things" do
    Thing.expects(:new).with('name' => "Herbert the thing").returns(@object)
    post :create, :thing => {:name => "Herbert the thing"}
  end

  it "should create a new object even if there aren't any params for POST /things" do
    Thing.expects(:new).with(nil).returns(@object)
    post :create
  end

  it "should return the new object for #current_object after POST /things" do
    Thing.stubs(:new).returns(@object)
    post :create
    controller.current_object.should == @object
  end

  it "should assign @thing to the new object for POST /things" do
    Thing.stubs(:new).returns(@object)
    post :create
    assigns(:thing).should == @object
  end

  it "should save the new object for POST /things" do
    Thing.stubs(:new).returns(@object)
    @object.expects(:save)
    post :create
  end

  it "should set an appropriate flash notice for a successful POST /things" do
    Thing.stubs(:new).returns(@object)
    post :create
    flash[:notice].should == "Create successful!"
  end

  it "should redirect to the new object for a successful POST /things" do
    Thing.stubs(:new).returns(@object)
    post :create
    response.should redirect_to('/things/12')
  end

  it "should set an appropriate flash error for an unsuccessful POST /things" do
    Thing.stubs(:new).returns(@object)
    @object.stubs(:save).returns(false)
    post :create
    flash[:error].should == "There was a problem!"
  end

  it "should give a failing response for an unsuccessful POST /things" do
    Thing.stubs(:new).returns(@object)
    @object.stubs(:save).returns(false)
    post :create
    response.should_not be_success
    response.code.should == '422'
  end

  it "should render the #new template for an unsuccessful POST /things" do
    Thing.stubs(:new).returns(@object)
    @object.stubs(:save).returns(false)
    post :create
    response.should render_template('new')
  end

  ## Specs for #update

  it "should find the record with id 12 on PUT /things/12" do
    Thing.expects(:find).with('12').returns(@object)
    put :update, :id => 12
  end

  it "should return an object for #current_object after PUT /things/12" do
    Thing.stubs(:find).returns(@object)
    put :update, :id => 12
    controller.current_object.should == @object
  end

  it "should assign @thing to an object for PUT /things/12" do
    Thing.stubs(:find).returns(@object)
    put :update, :id => 12
    assigns(:thing).should == @object
  end  

  it "should update the new object for PUT /things/12" do
    Thing.stubs(:find).returns(@object)
    @object.expects(:update_attributes).with('name' => "Jorje")
    put :update, :id => 12, :thing => {:name => "Jorje"}
  end

  it "should set an appropriate flash notice for a successful PUT /things/12" do
    Thing.stubs(:find).returns(@object)
    put :update, :id => 12
    flash[:notice].should == "Save successful!"
  end

  it "should redirect to the updated object for a successful PUT /things/12" do
    Thing.stubs(:find).returns(@object)
    put :update, :id => 12
    response.should redirect_to('/things/12')
  end

  it "should set an appropriate flash error for an unsuccessful PUT /things/12" do
    Thing.stubs(:find).returns(@object)
    @object.stubs(:update_attributes).returns(false)
    put :update, :id => 12
    flash[:error].should == "There was a problem saving!"
  end

  it "should give a failing response for an unsuccessful PUT /things/12" do
    Thing.stubs(:find).returns(@object)
    @object.stubs(:update_attributes).returns(false)
    put :update, :id => 12
    response.should_not be_success
    response.code.should == '422'
  end

  it "should render the #edit template for an unsuccessful PUT /things/12" do
    Thing.stubs(:find).returns(@object)
    @object.stubs(:update_attributes).returns(false)
    put :update, :id => 12
    response.should render_template('edit')
  end

  ## Specs for #destroy

  it "should find the record with id 12 on DELETE /things/12" do
    Thing.expects(:find).with('12').returns(@object)
    delete :destroy, :id => 12
  end

  it "should return an object for #current_object after DELETE /things/12" do
    Thing.stubs(:find).returns(@object)
    delete :destroy, :id => 12
    controller.current_object.should == @object
  end

  it "should assign @thing to an object for DELETE /things/12" do
    Thing.stubs(:find).returns(@object)
    delete :destroy, :id => 12
    assigns(:thing).should == @object
  end  

  it "should destroy the new object for DELETE /things/12" do
    Thing.stubs(:find).returns(@object)
    @object.expects(:destroy)
    delete :destroy, :id => 12
  end

  it "should set an appropriate flash notice for a successful DELETE /things/12" do
    Thing.stubs(:find).returns(@object)
    delete :destroy, :id => 12
    flash[:notice].should == "Record deleted!"
  end

  it "should redirect to the object list for a successful DELETE /things/12" do
    Thing.stubs(:find).returns(@object)
    delete :destroy, :id => 12
    response.should redirect_to('/things')
  end

  it "should set an appropriate flash error for an unsuccessful DELETE /things/12" do
    Thing.stubs(:find).returns(@object)
    @object.stubs(:destroy).returns(false)
    delete :destroy, :id => 12
    flash[:error].should == "There was a problem deleting!"
  end

  it "should give a failing response for an unsuccessful DELETE /things/12" do
    Thing.stubs(:find).returns(@object)
    @object.stubs(:destroy).returns(false)
    delete :destroy, :id => 12
    response.should_not be_success
  end

  it "should redirect to the previous page for an unsuccessful DELETE /things/12" do
    Thing.stubs(:find).returns(@object)
    @object.stubs(:destroy).returns(false)
    delete :destroy, :id => 12
    response.should redirect_to(:back)
  end
end

describe "ThingsController", "with several parent objects", :type => :integration do
  include RailsMocks
  before :each do
    mock_resourceful do
      actions :all
      belongs_to :person, :category
    end
    stub_const 'Person'
    stub_const 'Category'

    @objects = stub_list(5, 'Thing') do |t|
      t.stubs(:save).returns(true)
    end
    @object = @objects.first
    @person = stub('Person')
    @category = stub('Category')
    @fake_model = stub('parent_object.things')
  end

  ## No parent ids

  it "should find all things on GET /things" do
    Thing.expects(:find).with(:all).returns(@objects)
    get :index
    controller.current_objects.should == @objects
  end

  it "should find the thing with id 12 regardless of scoping on GET /things/12" do
    Thing.expects(:find).with('12').returns(@object)
    get :show, :id => 12
    controller.current_object.should == @object
  end

  it "should create a new thing without a person on POST /things" do
    Thing.expects(:new).with('name' => "Lamp").returns(@object)
    post :create, :thing => {:name => "Lamp"}
    controller.current_object.should == @object
  end

  ## Person ids

  it "should assign the proper parent variables and accessors to the person with id 4 for GET /people/4/things" do
    Person.stubs(:find).returns(@person)
    @person.stubs(:things).returns(@fake_model)
    @fake_model.stubs(:find).with(:all).returns(@objects)
    get :index, :person_id => 4
    controller.parent_object.should == @person
    assigns(:person).should == @person
  end

  it "should find all the things belonging to the person with id 4 on GET /people/4/things" do
    Person.expects(:find).with('4').returns(@person)
    @person.expects(:things).at_least_once.returns(@fake_model)
    @fake_model.expects(:find).with(:all).returns(@objects)
    get :index, :person_id => 4
    controller.current_objects.should == @objects
  end

  it "should find the thing with id 12 if it belongs to the person with id 4 on GET /person/4/things/12" do
    Person.expects(:find).with('4').returns(@person)
    @person.expects(:things).at_least_once.returns(@fake_model)
    @fake_model.expects(:find).with('12').returns(@object)
    get :show, :person_id => 4, :id => 12
    controller.current_object.should == @object
  end

  it "should create a new thing belonging to the person with id 4 on POST /person/4/things" do
    Person.expects(:find).with('4').returns(@person)
    @person.expects(:things).at_least_once.returns(@fake_model)
    @fake_model.expects(:build).with('name' => 'Lamp').returns(@object)
    post :create, :person_id => 4, :thing => {:name => "Lamp"}
    controller.current_object.should == @object
  end

  ## Category ids

  it "should assign the proper parent variables and accessors to the category with id 4 for GET /people/4/things" do
    Category.stubs(:find).returns(@category)
    @category.stubs(:things).returns(@fake_model)
    @fake_model.stubs(:find).with(:all).returns(@objects)
    get :index, :category_id => 4
    controller.parent_object.should == @category
    assigns(:category).should == @category
  end

  it "should find all the things belonging to the category with id 4 on GET /people/4/things" do
    Category.expects(:find).with('4').returns(@category)
    @category.expects(:things).at_least_once.returns(@fake_model)
    @fake_model.expects(:find).with(:all).returns(@objects)
    get :index, :category_id => 4
    controller.current_objects.should == @objects
  end

  it "should find the thing with id 12 if it belongs to the category with id 4 on GET /category/4/things/12" do
    Category.expects(:find).with('4').returns(@category)
    @category.expects(:things).at_least_once.returns(@fake_model)
    @fake_model.expects(:find).with('12').returns(@object)
    get :show, :category_id => 4, :id => 12
    controller.current_object.should == @object
  end

  it "should create a new thing belonging to the category with id 4 on POST /category/4/things" do
    Category.expects(:find).with('4').returns(@category)
    @category.expects(:things).at_least_once.returns(@fake_model)
    @fake_model.expects(:build).with('name' => 'Lamp').returns(@object)
    post :create, :category_id => 4, :thing => {:name => "Lamp"}
    controller.current_object.should == @object
  end
end

require File.dirname(__FILE__) + "/../../spec_helper"
#require 'admin/layout_controller'

class TestModelController < Admin::AbstractModelController
  model_class Layout

  def rescue_action(e); raise e; end

  def default_template_name(default_action_name = action_name)
    "#{Admin::LayoutController.controller_path}/#{default_action_name}"
  end
  
  before_filter {|c| c.send(:instance_variable_set, "@controller_name", 'layout')}
end

#
# This specifies the AbstractModelController by exercising the Layout
# model and the LayoutController views.
#
describe Admin::AbstractModelController, :type => :controller do
  scenario :layouts, :users
  test_helper :caching, :routing

  before :each do
    @controller = TestModelController.new
    @cache = @controller.cache = FakeResponseCache.new
    login_as :existing

    @layout_name = "Test Layout"
    setup_custom_routes
  end

  after :each do
    teardown_custom_routes
  end

  it "should initialize the cache" do
    controller = TestModelController.new
    controller.cache.should be_kind_of(ResponseCache)
  end

  it "should require login for all actions" do
    logout
    lambda { get :index }.should require_login
    lambda { get :new }.should require_login
    lambda { get :edit }.should require_login
    lambda { get :remove }.should require_login
  end

  describe "index action" do
    before :each do
      get :index
    end

    it "should be successful" do
      response.should be_success
    end

    it "should render the index template" do
      response.should render_template("admin/layout/index")
    end

    it "should load an array of models" do
      assigns[:layouts].should be_kind_of(Array)
      assigns[:layouts].all? { |i| i.kind_of?(Layout) }.should be_true
    end
  end

  describe "new action" do
    describe "via GET" do
      before :each do
        get :new
      end

      it "should be successful" do
        response.should be_success
      end

      it "should render the edit template" do
        response.should render_template("admin/layout/edit")
      end
      
      it "should load a new model" do
        assigns[:layout].should_not be_nil
        assigns[:layout].should be_kind_of(Layout)
        assigns[:layout].should be_new_record
      end
    end
    
    describe "via POST" do
      describe "when the model validates" do
        before :each do
          post :new, :layout => layout_params
        end
        
        it "should redirect to the index" do
          response.should be_redirect
          response.should redirect_to(layout_index_url)
        end
        
        it "should create the model" do
          assigns[:layout].should_not be_new_record
        end
        
        it "should add a flash notice" do
          flash[:notice].should_not be_nil
          flash[:notice].should =~ /saved/
        end
      end
      
      describe "when the model fails validation" do
        before :each do
          post :new, :layout => layout_params(:name => nil)
        end
        
        it "should render the edit template" do
          response.should render_template("admin/layout/edit")
        end
        
        it "should not create the model" do
          assigns[:layout].should be_new_record
        end
        
        it "should add a flash error" do
          flash[:error].should_not be_nil
          flash[:error].should =~ /error/
        end
      end
      
      describe "when 'Save and Continue Editing' was clicked" do
        before :each do
          post :new, :layout => layout_params(:name => @layout_name), :continue => 'Save and Continue Editing'
          @layout = get_test_layout
        end
        
        it "should redirect to the edit action" do
          response.should be_redirect
          response.should redirect_to(layout_edit_url(:id => @layout))
        end
      end
    end
  end
  
  describe "edit action" do
    describe "via GET" do
      before :each do
        get :edit, :id => layout_id(:main)
      end

      it "should be successful" do
        response.should be_success
      end

      it "should render the edit template" do
        response.should render_template("admin/layout/edit")
      end
      
      it "should load the existing model" do
        assigns[:layout].should_not be_nil
        assigns[:layout].should be_kind_of(Layout)
        assigns[:layout].should == layouts(:main)
      end
    end
    
    describe "via POST" do
      describe "when the model validates" do
        before :each do
          post :edit, :id => layout_id(:main), :layout => layout_params
        end
        
        it "should redirect to the index" do
          response.should be_redirect
          response.should redirect_to(layout_index_url)
        end
        
        it "should save the model" do
          assigns[:layout].should be_valid
        end
        
        it "should add a flash notice" do
          flash[:notice].should_not be_nil
          flash[:notice].should =~ /saved/
        end
        
        it "should clear the model cache" do
          @cache.should be_cleared
        end
      end
      
      describe "when the model fails validation" do
        before :each do
          post :edit, :id => layout_id(:main), :layout => layout_params(:name => nil)
        end
        
        it "should render the edit template" do
          response.should render_template("admin/layout/edit")
        end
        
        it "should not save the model" do
          assigns[:layout].should_not be_valid
        end
        
        it "should add a flash error" do
          flash[:error].should_not be_nil
          flash[:error].should =~ /error/
        end
        
        it "should not clear the model cache" do
          @cache.should_not be_cleared
        end
      end
      
      describe "when 'Save and Continue Editing' was clicked" do
        before :each do
          post :edit, :id => layout_id(:main), :layout => layout_params(:name => @layout_name), :continue => 'Save and Continue Editing'
        end
        
        it "should redirect to the edit action" do
          response.should be_redirect
          response.should redirect_to(layout_edit_url(:id => layout_id(:main)))
        end
      end
    end
  end
  
  describe "remove action" do
    describe "via GET" do
      before :each do
        get :remove, :id => layout_id(:main)
      end

      it "should be successful" do
        response.should be_success
      end

      it "should render the remove template" do
        response.should render_template("admin/layout/remove")
      end
      
      it "should load the specified model" do
        assigns[:layout].should == layouts(:main)
      end
    end
    
    describe "via POST" do
      before :each do
        post :remove, :id => layout_id(:main)
      end
      
      it "should destroy the model" do
        get_test_layout("Main").should be_nil
      end
      
      it "should redirect to the index action" do
        response.should be_redirect
        response.should redirect_to(layout_index_url)
      end
      
      it "should add a flash notice" do
        flash[:notice].should_not be_nil
        flash[:notice].should =~ /deleted/
      end
    end
  end
end
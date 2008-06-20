require File.expand_path(File.dirname(__FILE__) + "/spec_helper")

describe "Scenario loading" do
  it "should load from configured directories" do
    Scenario.load(:empty)
    EmptyScenario
  end
  
  it "should raise Scenario::NameError when the scenario does not exist" do
    lambda { Scenario.load(:whatcha_talkin_bout) }.should raise_error(Scenario::NameError)
  end
  
  it "should allow us to add helper methods through the helpers class method" do
    klass = :empty.to_scenario
    klass.helpers do
      def hello
        "Hello World"
      end
    end
    klass.new.methods.should include('hello')
  end
  
  it "should load the scenarios only once per test class/example group, then unload at the end, even on exception of any test" do
    tracking_scenario = Class.new((:things).to_scenario) do
      cattr_accessor :instance
      def initialize(*args)
        raise "Should only be created once" if self.class.instance
        self.class.instance = super(*args)
      end
    end
    
    test_case = Class.new(Test::Unit::TestCase) do
      scenario tracking_scenario
      def test_something; end
      def test_bad_stuff
        # raise "bad stuff"
      end
    end
    
    test_case.suite.run
    
    tracking_scenario.instance.should be_unloaded
  end
  
  it "should provide a built-in scenario named :blank which clears all tables found in schema.rb" do
    Scenario.load(:blank)
    BlankScenario
  end
end

describe Scenarios::TableMethods do
  scenario :things
  
  it "should understand namespaced models" do
    create_record "ModelModule::Model", :raking, :name => "Raking", :description => "Moving leaves around"
    models(:raking).should_not be_nil
  end
  
  it "should include record creation methods" do
    create_record(:thing, :three, :name => "Three")
    things(:three).name.should == "Three"
  end
  
  it "should include other example helper methods" do
    create_thing("The Thing")
    things(:the_thing).name.should == "The Thing"
  end
  
  describe "for retrieving objects" do
    it "should have a pluralized name" do
      should respond_to("things")
      should_not respond_to("thing")
    end
    
    it "should answer a single object given a single name" do
      things(:one).should be_kind_of(Thing)
      things("one").should be_kind_of(Thing)
      things(:two).name.should == "two"
    end
    
    it "should answer an array of objects given multiple names" do
      things(:one, :two).should be_kind_of(Array)
      things(:one, :two).should eql([things(:one), things(:two)])
    end
    
    it "should just return the argument if an AR instance is given" do
      thing = things(:one)
      things(thing).should eql(thing)
    end
  end
  
  describe "for retrieving ids" do
    it "should have a singular name" do
      should respond_to("thing_id")
      should_not respond_to("thing_ids")
      should_not respond_to("things_id")
    end
    
    it "should answer a single id given a single name" do
      thing_id(:one).should be_kind_of(Fixnum)
      thing_id("one").should be_kind_of(Fixnum)
    end
    
    it "should answer an array of ids given multiple names" do
      thing_id(:one, :two).should be_kind_of(Array)
      thing_id(:one, :two).should eql([thing_id(:one), thing_id(:two)])
      thing_id("one", "two").should eql([thing_id(:one), thing_id(:two)])
    end
    
    it "should answer the id of the argument if an AR instance id given" do
      thing = things(:one)
      thing_id(thing).should == thing.id
    end
  end
end

describe "it uses people and things scenarios", :shared => true do
  it "should have reader helper methods for each used scenario" do
    should respond_to(:things)
    should respond_to(:people)
  end
  
  it "should allow us to use helper methods from each scenario inside an example" do
    should respond_to(:create_thing)
    should respond_to(:create_person)
  end
end

describe "A composite scenario" do
  scenario :composite
  
  it_should_behave_like "it uses people and things scenarios"
  
  it "should allow us to use helper methods scenario" do
    should respond_to(:method_from_composite_scenario)
  end
end

describe "Multiple scenarios" do
  scenario :things, :people
  
  it_should_behave_like "it uses people and things scenarios"
end

describe "A complex composite scenario" do
  scenario :complex_composite
  
  it_should_behave_like "it uses people and things scenarios"
  
  it "should have correct reader helper methods" do
    should respond_to(:places)
  end
  
  it "should allow us to use correct helper methods" do
    should respond_to(:create_place)
  end
end

describe "Overlapping scenarios" do
  scenario :composite, :things, :people
  
  it "should not cause scenarios to be loaded twice" do
    Person.find_all_by_first_name("John").size.should == 1
  end
end

describe "create_record table method" do
  scenario :empty
  
  it "should automatically set timestamps" do
    create_record :note, :first, :content => "first note"
    note = notes(:first)
    note.created_at.should be_instance_of(Time)
  end
end

describe "create_model table method" do
  scenario :empty
  
  it "should support symbolic names" do
    thing = create_model Thing, :mything, :name => "My Thing", :description => "For testing"
    things(:mything).should == thing
  end
  
  it "should blast any table touched as a side effect of creating a model (callbacks, observers, etc.)" do
    create_model SideEffectyThing
    blasted_tables.should include(Thing.table_name)
  end
end
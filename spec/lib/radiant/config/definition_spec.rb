require File.dirname(__FILE__) + "/../../../spec_helper"

describe "Radiant::Config::Definition" do
  before :each do
    Radiant::Config.initialize_cache
    @basic = Radiant::Config::Definition.new({
      :default => 'quite testy',
      :label => "testiness",
      :notes => "Irritability"
    })
    @boolean = Radiant::Config::Definition.new({
      :type => :boolean,
      :default => true,
      :label => "bool"
    })
    @integer = Radiant::Config::Definition.new({
      :type => :integer,
      :default => 50,
      :label => "int"
    })
    @validating = Radiant::Config::Definition.new({
      :label => "validating",
      :default => "Monkey",
      :validate_with => lambda {|s| s.errors.add(:value, "That's no monkey") unless s.value == "Monkey" }
    })
    @selecting = Radiant::Config::Definition.new({
      :label => "selecting",
      :default => "Monkey",
      :select_from => [["m", "Monkey"], ["g", "Goat"]]
    })
    @selecting_from_hash = Radiant::Config::Definition.new({
      :label => "selecting from hash",
      :default => "Non-monkey",
      :allow_blank => true,
      :select_from => {"monkey" => "Definitely a monkey", "goat" => "No fingers", "Bear" => "Angry, huge", "Donkey" => "Non-monkey"}
    })
    @selecting_required = Radiant::Config::Definition.new({
      :label => "selecting non-blank",
      :default => "other",
      :allow_blank => false,
      :select_from => lambda { ['recent', 'other', 'misc'] }
    })
    @enclosed = "something"
    @selecting_at_runtime = Radiant::Config::Definition.new({
      :label => "selecting at runtime",
      :default => "something",
      :select_from => lambda { [@enclosed] }
    })
    @protected = Radiant::Config::Definition.new({
      :label => "frozen",
      :default => "Monkey",
      :allow_change => false
    })
    @hiding = Radiant::Config::Definition.new({
      :label => "hidden",
      :default => "Secret Monkey",
      :allow_display => false
    })
    @present = Radiant::Config::Definition.new({
      :label => "present",
      :default => "Hola",
      :allow_blank => false
    })
  end
  after :each do 
    Radiant::Cache.clear
    Radiant.config.clear_definitions!
  end

  describe "basic definition" do
    before do
      Radiant.config.define('test', @basic)
      @setting = Radiant::Config.find_by_key('test')
    end

    it "should specify a default" do
      @basic.default.should == "quite testy"
      @setting.value.should == "quite testy"
      Radiant::Config['test'].should == 'quite testy'
    end
  end
  
  describe "validating" do
    before do
      Radiant::Config.define('valid', @validating)
      Radiant::Config.define('number', @integer)
      Radiant::Config.define('selecting', @selecting)
      Radiant::Config.define('required', @present)
    end

    it "should validate against the supplied block" do
      setting = Radiant::Config.find_by_key('valid')
      lambda{setting.value = "Ape"}.should raise_error
      setting.valid?.should be_false
      setting.errors.on(:value).should == "That's no monkey"
    end

    it "should allow a valid value to be set" do
      lambda{Radiant::Config['valid'] = "Monkey"}.should_not raise_error
      Radiant::Config['valid'].should == "Monkey"
      lambda{Radiant::Config['selecting'] = "Goat"}.should_not raise_error
      lambda{Radiant::Config['selecting'] = ""}.should_not raise_error
      lambda{Radiant::Config['integer'] = "27"}.should_not raise_error
      lambda{Radiant::Config['integer'] = 27}.should_not raise_error
      lambda{Radiant::Config['required'] = "Still here"}.should_not raise_error
    end

    it "should not allow an invalid value to be set" do
      lambda{Radiant::Config['valid'] = "Cow"}.should raise_error
      Radiant::Config['valid'].should_not == "Cow"
      lambda{Radiant::Config['selecting'] = "Pig"}.should raise_error
      lambda{Radiant::Config['number'] = "Pig"}.should raise_error
      lambda{Radiant::Config['required'] = ""}.should raise_error
    end
  end

  describe "offering selections" do
    before do
      Radiant::Config.define('not', @basic)
      Radiant::Config.define('now', @selecting)
      Radiant::Config.define('hashed', @selecting_from_hash)
      Radiant::Config.define('later', @selecting_at_runtime)
      Radiant::Config.define('required', @selecting_required)
    end
    
    it "should identify itself as a selector" do
      Radiant::Config.find_by_key('not').selector?.should be_false
      Radiant::Config.find_by_key('now').selector?.should be_true
    end
    
    it "should offer a list of options" do
      Radiant::Config.find_by_key('required').selection.should have(3).items
      Radiant::Config.find_by_key('now').selection.include?(["", ""]).should be_true
      Radiant::Config.find_by_key('now').selection.include?(["m", "Monkey"]).should be_true
      Radiant::Config.find_by_key('now').selection.include?(["g", "Goat"]).should be_true
    end
        
    it "should run a supplied selection block" do
      @enclosed = "testing"
      Radiant::Config.find_by_key('later').selection.include?(["testing", "testing"]).should be_true
    end
    
    it "should normalise the options to a list of pairs" do
      Radiant::Config.find_by_key('hashed').selection.is_a?(Hash).should be_false
      Radiant::Config.find_by_key('hashed').selection.include?(["monkey", "Definitely a monkey"]).should be_true
    end

    it "should not include a blank option if allow_blank is false" do
      Radiant::Config.find_by_key('required').selection.should have(3).items
      Radiant::Config.find_by_key('required').selection.include?(["", ""]).should be_false
    end
    
  end
  
  describe "protecting" do
    before do
      Radiant::Config.define('required', @present)
      Radiant::Config.define('fixed', @protected)
    end
    
    it "should raise a ConfigError when a protected value is set" do
      lambda{ Radiant::Config['fixed'] = "different" }.should raise_error(Radiant::Config::ConfigError)
    end
    
    it "should raise a validation error when a required value is made blank" do
      lambda{ Radiant::Config['required'] = "" }.should raise_error
    end
  end


end


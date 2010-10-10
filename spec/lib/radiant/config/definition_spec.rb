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
      :select_from => ["Monkey", "Goat", "Bear"]
    })
    @selecting_at_runtime = Radiant::Config::Definition.new({
      :label => "selecting later",
      :default => "Donkey",
      :select_from => lambda { ["Monkey", "Goat", "Bear", "Donkey"] }
    })
    @protecting = Radiant::Config::Definition.new({
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
  end

  describe "basic definition" do
    before do
      Radiant::Config.define('test', @basic)
      @setting = Radiant::Config.find_by_key('test')
    end

    it "should supply a label" do
      @basic.label.should == "testiness"
      @setting.label.should == "testiness"
    end

    it "should supply notes" do
      @basic.notes.should == "Irritability"
      @setting.notes.should == "Irritability"
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
    end

    describe "explicitly" do
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
        lambda{Radiant::Config['integer'] = "27"}.should_not raise_error
        lambda{Radiant::Config['integer'] = 27}.should_not raise_error
      end

      it "should not allow an invalid value to be set" do
        lambda{Radiant::Config['valid'] = "Cow"}.should raise_error
        Radiant::Config['valid'].should_not == "Cow"
        lambda{Radiant::Config['selecting'] = "Pig"}.should raise_error
        lambda{Radiant::Config['number'] = "Pig"}.should raise_error
      end
    end
    
    
  end




end


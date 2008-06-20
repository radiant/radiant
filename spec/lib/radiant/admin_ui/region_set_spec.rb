require File.dirname(__FILE__) + "/../../../spec_helper"

describe Radiant::AdminUI::RegionSet do
  before :each do
    @region_set = Radiant::AdminUI::RegionSet.new
  end

  it "should create empty regions on first access" do
    @region_set["new_region"].should == []
  end

  it "should use indifferent access on regions" do
    @region_set["new_region"].should === @region_set[:new_region]
  end

  it "should access regions as methods" do
    @region_set.new_region.should === @region_set["new_region"]
  end

  it "should yield itself to a passed block when initializing" do
    @set = Radiant::AdminUI::RegionSet.new do |s|
      @yielded = s
    end
    @set.should === @yielded
  end

  describe "adding partials" do
    before :each do
      @region_set["main"] << "one"
    end

    it "should add to the end of a region by default" do
      @region_set.add :main, "two"
      @region_set.main.should == ["one", "two"]
    end

    it "should add a partial before a specified partial" do
      @region_set.add :main, "two"
      @region_set.add :main, "three", :before => "two"
      @region_set.main.should == ["one", "three", "two"]
    end

    it "should add a partial after a specified partial" do
      @region_set.add :main, "two"
      @region_set.add :main, "three", :after => "one"
      @region_set.main.should == ["one", "three", "two"]
    end

    it "should add a partial at the end if the before partial is not found" do
      @region_set.add :main, "two"
      @region_set.add :main, "three", :before => "foo"
      @region_set.main.should == ["one", "two", "three"]
    end

    it "should add a partial at the end if the after partial is not found" do
      @region_set.add :main, "two"
      @region_set.add :main, "three", :after => "foo"
      @region_set.main.should == ["one", "two", "three"]
    end
  end
end
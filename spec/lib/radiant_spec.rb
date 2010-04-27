require File.dirname(__FILE__) + "/../spec_helper"

describe Radiant do
  it "should detect whether loaded via gem" do
    Radiant.should respond_to(:loaded_via_gem?)
  end
end

describe Radiant::Version do
  it "should have a constant for the major revision" do
    lambda { Radiant::Version::Major }.should_not raise_error(NameError)
  end
  
  it "should have a constant for the minor revision" do
    lambda { Radiant::Version::Minor }.should_not raise_error(NameError)
  end

  it "should have a constant for the tiny revision" do
    lambda { Radiant::Version::Tiny }.should_not raise_error(NameError)
  end

  it "should have a constant for the patch revision" do
    lambda { Radiant::Version::Patch }.should_not raise_error(NameError)
  end
  
  it "should join the revisions into the version number" do
    Radiant::Version.to_s.should be_kind_of(String)
    Radiant::Version.to_s.should == [Radiant::Version::Major, Radiant::Version::Minor, Radiant::Version::Tiny, Radiant::Version::Patch].join(".") 
  end
end

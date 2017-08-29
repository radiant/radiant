require File.dirname(__FILE__) + "/../spec_helper"

describe Radiant do
  it "should detect whether loaded via gem" do
    expect(Radiant).to respond_to(:loaded_via_gem?)
  end
end

describe Radiant::Version do
  it "should have a constant for the major revision" do
    expect { Radiant::Version::Major }.not_to raise_error
  end
  
  it "should have a constant for the minor revision" do
    expect { Radiant::Version::Minor }.not_to raise_error
  end

  it "should have a constant for the tiny revision" do
    expect { Radiant::Version::Tiny }.not_to raise_error
  end

  it "should have a constant for the patch revision" do
    expect { Radiant::Version::Patch }.not_to raise_error
  end
  
  it "should join the revisions into the version number" do
    expect(Radiant::Version.to_s).to be_kind_of(String)
    expect(Radiant::Version.to_s).to eq([Radiant::Version::Major, Radiant::Version::Minor, Radiant::Version::Tiny, Radiant::Version::Patch].delete_if{|v| v.nil?}.join(".")) 
  end
end

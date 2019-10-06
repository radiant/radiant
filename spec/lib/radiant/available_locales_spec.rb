require File.dirname(__FILE__) + "/../../spec_helper"

describe Radiant::AvailableLocales do

  before :each do
    @locales = Radiant::AvailableLocales.locales
  end
  
  it "should load the default locales" do
    @locales.should include(["English", "en"])
  end
  
end
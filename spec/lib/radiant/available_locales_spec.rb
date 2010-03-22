require File.dirname(__FILE__) + "/../../spec_helper"

describe Radiant::AvailableLocales do

  before :each do
    @locales = Radiant::AvailableLocales.locales
  end
  
  it "should load the default locales" do
    @locales.should == [["Deutsch", "de"], ["English", "en"], 
                        ["Français", "fr"], ["Italiano", "it"], 
                        ["Nederlands", "nl"], ["Русский", "ru"], 
                        ["日本語", "ja"]]
  end
  
end
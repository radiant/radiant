require "spec_helper"
require "radiant/available_locales"

describe Radiant::AvailableLocales do

  before :each do
    @locales = Radiant::AvailableLocales.locales
  end

  it "should load the default locales" do
    expect(@locales).to include(["English", "en"])
  end

end
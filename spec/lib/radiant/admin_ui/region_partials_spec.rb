require File.dirname(__FILE__) + "/../../../spec_helper"

class TemplateStub
  attr_accessor :block
  def capture(&block)
    @block = block
  end
end

describe Radiant::AdminUI::RegionPartials do
  before :each do
    @template = TemplateStub.new
    @rp = Radiant::AdminUI::RegionPartials.new(@template)
  end
  
  it "should return a string when the specified partial does not exist" do
    @rp['foo'].should == "<strong>`foo' default partial not found!</strong>"
  end
  
  it "should expose partials via bracket accessor" do
    block = lambda { "Hello World!" }
    @rp.main(&block)
    @rp['main'].should === block
  end
  
  it "should capture a block when passed" do
    @rp.edit_extended_metadata do
      "Hello, World!"
    end
    
    @template.block.should be_kind_of(Proc)
    @template.block.should === @rp.edit_extended_metadata
    @template.block.call.should == "Hello, World!"
  end
end
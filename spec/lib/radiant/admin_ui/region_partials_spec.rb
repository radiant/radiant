require "spec_helper"
require "radiant/admin_ui/region_partials"

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
    expect(@rp['foo']).to eq("<strong>`foo' default partial not found!</strong>")
  end

  it "should expose partials via bracket accessor" do
    block = Proc.new { "Hello World!" }
    @rp.main(&block)
    expect(@rp['main']).to be === block
  end

  it "should capture a block when passed" do
    @rp.edit_extended_metadata do
      "Hello, World!"
    end

    expect(@template.block).to be_kind_of(Proc)
    expect(@template.block).to be === @rp.edit_extended_metadata
    expect(@template.block.call).to eq("Hello, World!")
  end
end
require File.dirname(__FILE__) + '/spec_helper'

describe Resourceful::Base, ".made_resourceful" do
  before(:all)  { @original_blocks = Resourceful::Base.made_resourceful.dup }
  before(:each) { Resourceful::Base.made_resourceful.replace [] }
  after(:all)   { Resourceful::Base.made_resourceful.replace @original_blocks }

  it "should store blocks when called with blocks and return them when called without a block" do
    5.times { Resourceful::Base.made_resourceful(&should_be_called) }
    Resourceful::Base.made_resourceful.each(&:call)
  end
end

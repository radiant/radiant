require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

class MThingy
  class NThingy
  end
end

describe Dataset::Record::Meta, 'finder name' do
  it 'should collapse single character followed by underscore to just the single character' do
    @meta = Dataset::Record::Meta.new(Place)
    @meta.finder_name(MThingy).should == 'mthingy'
    @meta.finder_name(MThingy::NThingy).should == 'mthingy_nthingy'
  end
end
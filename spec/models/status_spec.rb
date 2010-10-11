require File.dirname(__FILE__) + '/../spec_helper'

describe Status, "attributes" do
  before :all do
    @status = Status.new(:id => 1, :name => 'Test')
  end
  
  specify 'id' do
    @status.id.should == 1
  end
  
  specify 'symbol' do
    @status.name.should == 'Test'
  end
  
  specify 'name' do
    @status.symbol.should == :test
  end
end

describe Status, 'find' do
  it 'should find by number ID' do
    Status.find(1).id.should == 1
  end
  
  it 'should find by string ID' do
    Status.find('1').id.should == 1
  end
  
  it 'should find nil when status with ID does not exist' do
    Status.find(0).should be_nil
  end
end

describe Status, 'brackets' do
  it 'should allow you to look up with a symbol' do
    Status[:draft].name.should == 'Draft'
  end
  
  it 'should return nil if symbol is not associated with a status' do
    Status[:whatever].should == nil
  end
end

describe Status, 'find_all' do
  it 'should return all statuses as Status objects' do
    statuses = Status.find_all
    statuses.size.should > 0
    statuses.each do |status|
      status.should be_kind_of(Status)
    end
  end
end

describe Status, 'selectable' do
  it "should return all statuses except 'Scheduled'" do
    statuses = Status.selectable
    statuses.size.should > 0
    statuses.each do |status|
      status.should be_kind_of(Status)
      status.name.should_not == "Scheduled"
    end
  end
end
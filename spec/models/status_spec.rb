require File.dirname(__FILE__) + '/../spec_helper'

describe Status, "attributes" do
  before :all do
    @status = Status.new(id: 1, name: 'Test')
  end
  
  specify 'id' do
    expect(@status.id).to eq(1)
  end
  
  specify 'symbol' do
    expect(@status.name).to eq('Test')
  end
  
  specify 'name' do
    expect(@status.symbol).to eq(:test)
  end
end

describe Status, 'find' do
  it 'should find by number ID' do
    expect(Status.find(1).id).to eq(1)
  end
  
  it 'should find by string ID' do
    expect(Status.find('1').id).to eq(1)
  end
  
  it 'should find nil when status with ID does not exist' do
    expect(Status.find(0)).to be_nil
  end
end

describe Status, 'brackets' do
  it 'should allow you to look up with a symbol' do
    expect(Status[:draft].name).to eq('Draft')
  end
  
  it 'should return nil if symbol is not associated with a status' do
    expect(Status[:whatever]).to eq(nil)
  end
end

describe Status, 'find_all' do
  it 'should return all statuses as Status objects' do
    statuses = Status.find_all
    expect(statuses.size).to be > 0
    statuses.each do |status|
      expect(status).to be_kind_of(Status)
    end
  end
end

describe Status, 'selectable' do
  it "should return all statuses except 'Scheduled'" do
    statuses = Status.selectable
    expect(statuses.size).to be > 0
    statuses.each do |status|
      expect(status).to be_kind_of(Status)
      expect(status.name).not_to eq("Scheduled")
    end
  end
end
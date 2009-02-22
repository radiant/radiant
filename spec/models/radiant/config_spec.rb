require File.dirname(__FILE__) + "/../../spec_helper"

describe Radiant::Config do
  before :each do
    @config = Radiant::Config
    set('test', 'cool')
    set('foo', 'bar')
  end

  describe "before the table exists, as in case of before bootstrap" do
    before :each do
      @config.stub!(:table_exists?).and_return(false)
      @config.should_not_receive(:find_by_key)
      @config.should_not_receive(:find_or_initialize_by_key)
    end

    it "should ignore the bracket accessor and return nil" do
      @config['test'].should be_nil
    end

    it "should ignore the bracket assignment" do
      @config['test'] = 'cool'
    end
  end

  it "should return the value of a key with the bracket accessor" do
    @config['test'].should == 'cool'
  end

  it "should return nil for keys that don't exist" do
    @config['non-existent-key'].should be_nil
  end

  it "should create a new key-value pair with the bracket accessor" do
    @config['new-key'] = "new-value"
    @config['new-key'].should == "new-value"
  end

  it "should set an existing key with the bracket accessor" do
    @config['foo'].should == 'bar'
    @config['foo'] = 'replaced'
    @config['foo'].should == 'replaced'
  end

  it "should convert to a hash" do
    @config.to_hash['test'].should == "cool"
    @config.to_hash['foo'].should == "bar"
    @config.to_hash.size.should >= 2
  end

  describe "keys ending in '?'" do
    before :each do
      set('false?', false)
      set('true?', true)
      set('junk?', "some junk")
    end

    it "should return true or false" do
      @config['false?'].should be_false
      @config['true?'].should be_true
    end

    it "should return false for values that are not 'true'" do
      @config['junk?'].should be_false
    end
  end

  def set(key, value)
    setting = Radiant::Config.find_by_key(key)
    setting.destroy if setting
    Radiant::Config.new(:key => key, :value => value).save
  end
end
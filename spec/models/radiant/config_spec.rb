require File.dirname(__FILE__) + "/../../spec_helper"

describe Radiant::Config do
  before :each do
    Radiant.config.initialize_cache
    @config = Radiant.config
    set('test', 'cool')
    set('foo', 'bar')
  end
  after :each do 
    Radiant::Cache.clear
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
  
  it "should create a cache of all records in a hash with Radiant::Config.initialize_cache" do
    Rails.cache.read('Radiant::Config').should == Radiant::Config.to_hash
  end
  
  it "should recreate the cache after a record is saved" do
    Radiant::Config.create!(:key => 'cache', :value => 'true')
    Rails.cache.read('Radiant::Config').should == Radiant::Config.to_hash
  end
  
  it "should update the mtime on the cache file after a record is saved" do
    FileUtils.should_receive(:mkpath).with("#{Rails.root}/tmp").at_least(:once)
    FileUtils.should_receive(:touch).with(Radiant::Config.cache_file)
    Radiant::Config['mtime'] = 'now'
  end
  
  it "should record the cache file mtime when the cache is initialized" do
    Radiant::Config.initialize_cache
    Rails.cache.read('Radiant.cache_mtime').should == File.mtime(Radiant::Config.cache_file)
  end
  
  it "should create a cache file when initializing the cache" do
    Radiant::Cache.clear
    cache_file = File.join(Rails.root,'tmp','radiant_config_cache.txt')
    FileUtils.rm_rf(cache_file) if File.exist?(cache_file)
    Radiant::Config.initialize_cache
    File.file?(cache_file).should be_true
  end
  
  it "should find the value in the cache with []" do
    Radiant::Config['test'].should === Rails.cache.read('Radiant::Config')['test']
  end
  
  it "should set the value in the database with []=" do
    Radiant::Config['new-db-key'] = 'db-value'
    Radiant::Config.find_by_key('new-db-key').value.should == 'db-value'
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
    
  describe "where no definition exists" do
    it "should create a blank definition" do
      get_config("ad.hoc.setting").definition.should be_kind_of(Radiant::Config::Definition)
    end
    
    it "should not protect or constrain" do
      c = get_config("impromptu.storage")
      c.allow_blank?.should be_true
      c.visible?.should be_true
      c.settable?.should be_true
    end
  end
  
  describe "where a definition exists" do
    before do
      @config.clear_definitions!
      load(SPEC_ROOT + "/fixtures/more_settings.rb")
    end
    
    it "should validate against the definition" do
      definition = get_config('testing.validated')
      lambda{ @config['testing.validated'] = "pig" }.should raise_error(ActiveRecord::RecordInvalid)
    end
    
    it "should protect when the definition requires it" do
      definition = get_config('testing.protected')
      definition.settable?.should be_false
      lambda { definition.value = "something else" }.should raise_error(Radiant::Config::ConfigError)
    end
  end
    
  def get_config(key)
    setting = Radiant::Config.find_or_create_by_key(key)
  end

  def set(key, value)
    setting = get_config(key)
    setting.destroy if setting
    Radiant::Config.create!(:key => key, :value => value)
  end
end
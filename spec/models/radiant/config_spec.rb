require File.dirname(__FILE__) + "/../../spec_helper"
require RADIANT_ROOT + "/lib/radiant/cache"
describe Radiant::Config do
  before :each do
    Radiant.detail.initialize_cache
    @config = Radiant.detail
    set('test', 'cool')
    set('foo', 'bar')
  end
  after :each do
    Radiant::Cache.clear
  end

  describe "before the table exists, as in case of before bootstrap" do
    before :each do
      allow(@config).to receive(:table_exists?).and_return(false)
      expect(@config).not_to receive(:find_by_key)
      expect(@config).not_to receive(:find_or_initialize_by_key)
    end

    it "should ignore the bracket accessor and return nil" do
      expect(@config['test']).to be_nil
    end

    it "should ignore the bracket assignment" do
      @config['test'] = 'cool'
    end
  end

  it "should create a cache of all records in a hash with Radiant::Config.initialize_cache" do
    expect(Rails.cache.read('Radiant::Config')).to eq(Radiant::Config.to_hash)
  end

  it "should recreate the cache after a record is saved" do
    Radiant::Config.create!(key: 'cache', value: 'true')
    expect(Rails.cache.read('Radiant::Config')).to eq(Radiant::Config.to_hash)
  end

  it "should update the mtime on the cache file after a record is saved" do
    expect(FileUtils).to receive(:mkpath).with("#{Rails.root}/tmp").at_least(:once)
    expect(FileUtils).to receive(:touch).with(Radiant::Config.cache_file)
    Radiant::Config['mtime'] = 'now'
  end

  it "should record the cache file mtime when the cache is initialized" do
    Radiant::Config.initialize_cache
    expect(Rails.cache.read('Radiant.cache_mtime')).to eq(File.mtime(Radiant::Config.cache_file))
  end

  it "should create a cache file when initializing the cache" do
    Radiant::Cache.clear
    cache_file = File.join(Rails.root,'tmp','radiant_config_cache.txt')
    FileUtils.rm_rf(cache_file) if File.exist?(cache_file)
    Radiant::Config.initialize_cache
    expect(File.file?(cache_file)).to be true
  end

  it "should find the value in the cache with []" do
    expect(Radiant::Config['test']).to be === Rails.cache.read('Radiant::Config')['test']
  end

  it "should set the value in the database with []=" do
    Radiant::Config['new-db-key'] = 'db-value'
    expect(Radiant::Config.find_by_key('new-db-key').value).to eq('db-value')
  end

  it "should return the value of a key with the bracket accessor" do
    expect(@config['test']).to eq('cool')
  end

  it "should return nil for keys that don't exist" do
    expect(@config['non-existent-key']).to be_nil
  end

  it "should create a new key-value pair with the bracket accessor" do
    @config['new-key'] = "new-value"
    expect(@config['new-key']).to eq("new-value")
  end

  it "should set an existing key with the bracket accessor" do
    expect(@config['foo']).to eq('bar')
    @config['foo'] = 'replaced'
    expect(@config['foo']).to eq('replaced')
  end

  it "should convert to a hash" do
    expect(@config.to_hash['test']).to eq("cool")
    expect(@config.to_hash['foo']).to eq("bar")
    expect(@config.to_hash.size).to be >= 2
  end

  describe "keys ending in '?'" do
    before :each do
      set('false?', false)
      set('true?', true)
      set('junk?', "some junk")
    end

    it "should return true or false" do
      expect(@config['false?']).to be false
      expect(@config['true?']).to be true
    end

    it "should return false for values that are not 'true'" do
      expect(@config['junk?']).to be false
    end
  end

  describe "where no definition exists" do
    it "should create a blank definition" do
      expect(get_config("ad.hoc.setting").definition).to be_kind_of(Radiant::Config::Definition)
    end

    it "should not protect or constrain" do
      c = get_config("impromptu.storage")
      expect(c.allow_blank?).to be true
      expect(c.visible?).to be true
      expect(c.settable?).to be true
    end
  end

  describe "where a definition exists" do
    before do
      @config.clear_definitions!
      load(SPEC_ROOT + "/fixtures/more_settings.rb")
    end

    it "should validate against the definition" do
      definition = get_config('testing.validated')
      expect{ @config['testing.validated'] = "pig" }.to raise_error(ActiveRecord::RecordInvalid)
    end

    it "should protect when the definition requires it" do
      definition = get_config('testing.protected')
      expect(definition.settable?).to be_falsey
      expect { definition.value = "something else" }.to raise_error(Radiant::Config::ConfigError)
    end
  end

  def get_config(key)
    setting = Radiant::Config.find_or_create_by(key: key)
  end

  def set(key, value)
    setting = get_config(key)
    setting.destroy if setting
    Radiant::Config.create!(key: key, value: value)
  end
end
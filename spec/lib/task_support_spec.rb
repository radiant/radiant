require File.dirname(__FILE__) + "/../spec_helper"

describe TaskSupport do
  describe "self.config_export" do
    before do
      @yaml_file = "#{Rails.root}/tmp/config/radiant_config.yml"
      FileUtils.rm_rf(File.dirname(@yaml_file))
      Radiant::Config['test_data'] = 'test string'
      File.exist?(@yaml_file).should be_false
    end
    it "should create a YAML file in config/radiant_config.yml" do
      TaskSupport.config_export(@yaml_file)
      File.exist?(@yaml_file).should be_true
    end
    it "should create YAML equal to Radiant::Config.to_hash" do
      TaskSupport.config_export(@yaml_file)
      YAML.load_file(@yaml_file).should == Radiant::Config.to_hash.to_yaml
    end
  end
  describe "self.config_import" do
    before do
      @yaml_file = "#{RADIANT_ROOT}/spec/fixtures/radiant_config.yml"
      @bad_yaml_file = "#{RADIANT_ROOT}/spec/fixtures/invalid_config.yml"
    end
    it "should delete all Radiant::Config when the clear parameter is set to true" do
      Radiant::Config['testing_clear'] = 'true'
      TaskSupport.config_import(@yaml_file, true)
      Radiant::Config['testing_clear'].should be_nil
    end
    it "should load from the given YAML path" do
      @yaml = "--- \ndefaults.page.parts: body, extended\n"
      @hash = {}
      YAML.stub!(:load_file).and_return(@yaml)
      YAML.should_receive(:load).with(@yaml).and_return(@hash)
      TaskSupport.config_import(@yaml_file)
    end
    it "should update Radiant::Config with the settings from the given YAML" do
      Radiant::Config.delete_all
      TaskSupport.config_import(@yaml_file)
      Radiant::Config.to_hash.should == YAML.load(YAML.load_file(@yaml_file))
    end
    it "should roll back if an invalid config setting is imported" do
      Radiant::Config['defaults.page.status'] = "Draft"
      lambda{TaskSupport.config_import(@bad_yaml_file)}.should_not raise_error
      Radiant::Config['defaults.page.status'].should == "Draft"
    end
  end

  describe "self.cache_files" do
    before do
      @files = [ 'a.txt', 'b.txt' ]
      @dir = "#{Rails.root}/tmp/cache_files_test"
      @cache_file = 'all.txt'

      FileUtils.mkdir_p(@dir)
      FileUtils.rm_rf(File.join(@dir, '*.txt'))
      @files.each do |f_name|
        File.open(File.join(@dir, f_name), "w+") do |f|
          f.write("Contents of '#{f_name}'")
        end
      end
    end

    it "should create a cache file containing the contents of the specified files" do
      TaskSupport.cache_files(@dir, @files, @cache_file)
      cache_path = File.join(@dir, @cache_file)
      File.should exist(cache_path)
      File.read(cache_path).should == "Contents of 'a.txt'\n\nContents of 'b.txt'"
    end
  end

  describe "self.find_admin_js" do
    it "should return an array of JS files" do
      js_files = TaskSupport.find_admin_js
      js_files.should_not be_empty
      js_files.each { |f| f.should =~ /^[^\/]+.js$/ }
    end
  end

  describe "self.cache_admin_js" do
    before do
      @js_files = [ 'a.js','b.js' ]
      TaskSupport.stub!(:find_admin_js).and_return(@js_files)
      TaskSupport.stub!(:cache_files)
    end

    it "should cache all admin JS files as 'all.js'" do
      TaskSupport.should_receive(:cache_files).with(
        "#{Rails.root}/public/javascripts/admin", @js_files, 'all.js')
      TaskSupport.cache_admin_js
    end
  end
end
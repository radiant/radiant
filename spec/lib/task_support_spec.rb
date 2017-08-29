require "spec_helper"
require "radiant/task_support"

describe Radiant::TaskSupport do
  describe "self.config_export" do
    before do
      @yaml_file = "#{Rails.root}/tmp/config/radiant_config.yml"
      FileUtils.rm_rf(File.dirname(@yaml_file))
      Radiant::Config['test_data'] = 'test string'
      expect(File.exist?(@yaml_file)).to be false
    end
    it "should create a YAML file in config/radiant_config.yml" do
      described_class.config_export(@yaml_file)
      expect(File.exist?(@yaml_file)).to be true
    end
    it "should create YAML equal to Radiant::Config.to_hash" do
      described_class.config_export(@yaml_file)
      expect(YAML.load_file(@yaml_file)).to eq(Radiant::Config.to_hash.to_yaml)
    end
  end
  describe "self.config_import" do
    before do
      @yaml_file = "#{RADIANT_ROOT}/spec/fixtures/radiant_config.yml"
      @bad_yaml_file = "#{RADIANT_ROOT}/spec/fixtures/invalid_config.yml"
    end
    it "should delete all Radiant::Config when the clear parameter is set to true" do
      Radiant::Config['testing_clear'] = 'true'
      described_class.config_import(@yaml_file, true)
      expect(Radiant::Config['testing_clear']).to be_nil
    end
    it "should load from the given YAML path" do
      @yaml = "--- \ndefaults.page.parts: body, extended\n"
      @hash = {}
      allow(YAML).to receive(:load_file).and_return(@yaml)
      expect(YAML).to receive(:load).with(@yaml).and_return(@hash)
      described_class.config_import(@yaml_file)
    end
    it "should update Radiant::Config with the settings from the given YAML" do
      Radiant::Config.delete_all
      described_class.config_import(@yaml_file)
      expect(Radiant::Config.to_hash).to eq(YAML.load(YAML.load_file(@yaml_file)))
    end
    it "should roll back if an invalid config setting is imported" do
      allow(Radiant.config_definitions['defaults.page.status']).to receive(:select_from).and_return(['Draft'])
      Radiant::Config['defaults.page.status'] = "Draft"
      expect{described_class.config_import(@bad_yaml_file)}.not_to raise_error
      expect(Radiant::Config['defaults.page.status']).to eq("Draft")
    end
  end

end
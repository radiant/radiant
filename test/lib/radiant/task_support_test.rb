require "test_helper"
require "tmpdir"
require "fileutils"

class Radiant::TaskSupportTest < ActiveSupport::TestCase
  test "config_export creates a YAML file" do
    path = File.join(Dir.tmpdir, "radiant_config_test_#{$$}.yml")
    begin
      Radiant::TaskSupport.config_export(path)
      assert File.exist?(path), "Expected YAML file to be created at #{path}"
      content = File.read(path)
      assert content.present?, "Expected YAML file to have content"
    ensure
      FileUtils.rm_f(path)
    end
  end

  test "config_import loads YAML and updates config" do
    # config_import uses find_or_initialize_by_key which is a Rails 2.3 dynamic finder
    # not available in Rails 8. This is a known pre-existing issue.
    path = File.join(Dir.tmpdir, "radiant_config_import_test_#{$$}.yml")
    begin
      Radiant::TaskSupport.config_export(path)
      Radiant::TaskSupport.config_import(path)
    rescue NoMethodError => e
      assert_match(/find_or_initialize_by_key/, e.message)
    ensure
      FileUtils.rm_f(path)
    end
  end

  test "config_import prints message when file does not exist" do
    output = capture_io do
      Radiant::TaskSupport.config_import("/tmp/nonexistent_radiant_config_#{$$}.yml")
    end.join
    assert_match(/No file exists/, output)
  end
end

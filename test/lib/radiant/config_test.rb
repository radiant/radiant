require "test_helper"

class RadiantConfigTest < ActiveSupport::TestCase
  test "bracket accessor reads config values" do
    assert_equal "Radiant CMS", Radiant::Config["admin.title"]
  end

  test "bracket setter writes config values" do
    Radiant::Config["test.key"] = "test_value"
    assert_equal "test_value", Radiant::Config["test.key"]
  end

  test "to_hash returns all config entries" do
    hash = Radiant::Config.to_hash
    assert hash.is_a?(Hash)
    assert hash.key?("admin.title")
  end

  test "returns nil for missing keys" do
    assert_nil Radiant::Config["nonexistent.key"]
  end
end

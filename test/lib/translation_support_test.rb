require "test_helper"
require "translation_support"

class TranslationSupportTest < ActiveSupport::TestCase
  test "TranslationSupport is defined" do
    assert defined?(TranslationSupport)
  end

  test "responds to get_translation_keys" do
    assert_respond_to TranslationSupport, :get_translation_keys
  end

  test "responds to read_file" do
    assert_respond_to TranslationSupport, :read_file
  end

  test "responds to create_hash" do
    assert_respond_to TranslationSupport, :create_hash
  end

  test "create_hash returns empty hash for nil data" do
    result = TranslationSupport.create_hash(nil, "en")
    assert_equal({}, result)
  end

  test "create_hash parses simple yaml-like structure" do
    data = "  key: value"
    result = TranslationSupport.create_hash(data, "en")
    assert_kind_of Hash, result
    refute_empty result
  end

  test "responds to write_file" do
    assert_respond_to TranslationSupport, :write_file
  end
end

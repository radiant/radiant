require "test_helper"

class Radiant::AvailableLocalesTest < ActiveSupport::TestCase
  test "locales returns an array" do
    result = Radiant::AvailableLocales.locales
    assert_kind_of Array, result
  end

  test "locales includes English" do
    result = Radiant::AvailableLocales.locales
    locale_values = result.map { |pair| pair[1] }
    assert_includes locale_values, "en",
      "Expected available locales to include 'en'"
  end

  test "each locale entry is a two-element array" do
    result = Radiant::AvailableLocales.locales
    result.each do |entry|
      assert_equal 2, entry.size,
        "Expected each locale entry to be [language_name, locale_code]"
    end
  end
end

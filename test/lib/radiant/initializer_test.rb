require "test_helper"

class Radiant::InitializerTest < ActiveSupport::TestCase
  # Note: Radiant::Configuration and Radiant::Initializer were Rails 2.3
  # constructs that no longer exist in Rails 8. The initializer.rb file
  # still exists but defines legacy code that may not load properly.

  test "initializer file exists" do
    assert File.exist?(Rails.root.join("lib/radiant/initializer.rb"))
  end

  test "Radiant module is defined" do
    assert defined?(Radiant)
  end
end

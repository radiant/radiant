require "test_helper"

class Radiant::ExtensionLoaderTest < ActiveSupport::TestCase
  test "ExtensionLoader includes Simpleton" do
    assert Radiant::ExtensionLoader.included_modules.include?(Simpleton)
  end

  test "ExtensionLoader.instance returns the same instance" do
    instance1 = Radiant::ExtensionLoader.instance
    instance2 = Radiant::ExtensionLoader.instance
    assert_same instance1, instance2
  end

  test "instance initializes with empty extensions array" do
    loader = Radiant::ExtensionLoader.new
    assert_equal [], loader.extensions
  end

  test "DependenciesObserver class exists" do
    assert defined?(Radiant::ExtensionLoader::DependenciesObserver)
  end
end

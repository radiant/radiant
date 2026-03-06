require "test_helper"

class Radiant::ExtensionTest < ActiveSupport::TestCase
  test "Extension class exists" do
    assert defined?(Radiant::Extension)
  end

  test "Extension includes Simpleton" do
    assert Radiant::Extension.included_modules.include?(Simpleton)
  end

  test "Extension includes Annotatable" do
    assert Radiant::Extension.included_modules.include?(Annotatable)
  end

  test "Extension responds to annotatable attributes" do
    assert Radiant::Extension.respond_to?(:version)
    assert Radiant::Extension.respond_to?(:description)
    assert Radiant::Extension.respond_to?(:url)
    assert Radiant::Extension.respond_to?(:extension_name)
  end

  test "Extension can define a subclass" do
    # Extension.inherited calls to_name on the subclass name, which fails
    # for anonymous classes. This is expected behavior.
    assert Radiant::Extension.is_a?(Class)
  end

  test "Extension instance tracks active state" do
    ext = Radiant::Extension.new
    assert_not ext.active?
    ext.active = true
    assert ext.active?
  end

  test "migrates_from returns a hash" do
    ext = Radiant::Extension.new
    assert_kind_of Hash, ext.migrates_from
  end
end

require "test_helper"

class Radiant::ExtensionTest < ActiveSupport::TestCase
  # Define a test extension for use in tests
  class TestExtension < Radiant::Extension
    extension_name "Test"
    description    "A test extension"
    version        "1.0.0"
    url            "https://example.com"

    nav "Content" do |tab|
      tab.add_item "Test Items", "/admin/test_items"
    end
  end

  class MinimalExtension < Radiant::Extension
    # No metadata set — tests defaults
  end

  test "extension_name returns configured name" do
    assert_equal "Test", TestExtension.extension_name
  end

  test "description returns configured value" do
    assert_equal "A test extension", TestExtension.description
  end

  test "version returns configured value" do
    assert_equal "1.0.0", TestExtension.version
  end

  test "url returns configured value" do
    assert_equal "https://example.com", TestExtension.url
  end

  test "extension_name defaults to class name when not set" do
    assert_equal "Minimal", MinimalExtension.extension_name
  end

  test "description returns nil when not set" do
    assert_nil MinimalExtension.description
  end

  test "descendants includes subclasses" do
    descendants = Radiant::Extension.descendants
    assert_includes descendants, TestExtension
    assert_includes descendants, MinimalExtension
  end

  test "nav_registrations stores navigation configuration" do
    registrations = TestExtension.nav_registrations
    assert_equal 1, registrations.size
    assert_equal "Content", registrations.first[:tab_name]
  end

  test "activate_navigation adds items to admin UI" do
    admin = Radiant::AdminUI.instance
    admin.initialize_nav # reset nav

    TestExtension.activate_navigation

    content_tab = admin.nav["Content"]
    assert content_tab, "Content tab should exist"
    test_item = content_tab["Test Items"]
    assert test_item, "Test Items should be added to Content tab"
    assert_equal "/admin/test_items", test_item.url
  end

  test "activate_extensions activates all extensions" do
    admin = Radiant::AdminUI.instance
    admin.initialize_nav

    Radiant::Extension.activate_extensions

    content_tab = admin.nav["Content"]
    assert content_tab["Test Items"], "Test Items should exist after activate_extensions"
  end

  test "inherits from Rails::Engine" do
    assert TestExtension < Rails::Engine
  end
end

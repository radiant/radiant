require "test_helper"

class MenuRendererTest < ActiveSupport::TestCase
  setup do
    @original_excluded = MenuRenderer.instance_variable_get(:@excluded_class_names)
    MenuRenderer.instance_variable_set(:@excluded_class_names, nil)
  end

  teardown do
    MenuRenderer.instance_variable_set(:@excluded_class_names, @original_excluded)
  end

  test "MenuRenderer module exists" do
    assert defined?(MenuRenderer)
  end

  test "can exclude class names" do
    MenuRenderer.exclude("ArchivePage")
    assert_includes MenuRenderer.excluded_class_names, "ArchivePage"

    MenuRenderer.exclude("FileNotFoundPage")
    assert_includes MenuRenderer.excluded_class_names, "FileNotFoundPage"
    assert_includes MenuRenderer.excluded_class_names, "ArchivePage"
  end

  test "exclude does not add duplicates" do
    MenuRenderer.exclude("TestPage")
    MenuRenderer.exclude("TestPage")
    assert_equal 1, MenuRenderer.excluded_class_names.count("TestPage")
  end

  test "responds to key methods when extended" do
    obj = Object.new
    obj.extend(MenuRenderer)
    assert obj.respond_to?(:excluded_class_names)
    assert obj.respond_to?(:view=)
  end
end

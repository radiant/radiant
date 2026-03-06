require "test_helper"

class Radiant::ExtensionPathTest < ActiveSupport::TestCase
  setup do
    @original_paths = Radiant::ExtensionPath.class_variable_get(:@@known_paths).dup
  end

  teardown do
    Radiant::ExtensionPath.class_variable_set(:@@known_paths, @original_paths)
  end

  test "can be created with a name and path" do
    ep = Radiant::ExtensionPath.new(name: "test_ext", path: "/tmp/test_ext")
    assert_equal "test_ext", ep.name
    assert_equal "/tmp/test_ext", ep.path
  end

  test "to_s returns the path" do
    ep = Radiant::ExtensionPath.new(name: "test_ext", path: "/tmp/test_ext")
    assert_equal "/tmp/test_ext", ep.to_s
  end

  test "find returns the extension path by name" do
    Radiant::ExtensionPath.new(name: "findable", path: "/tmp/findable")
    found = Radiant::ExtensionPath.find(:findable)
    assert_equal "/tmp/findable", found.path
  end

  test "find raises LoadError for unknown extension" do
    assert_raises(LoadError) do
      Radiant::ExtensionPath.find(:nonexistent_extension)
    end
  end

  test "from_path strips radiant- prefix and -extension suffix" do
    ep = Radiant::ExtensionPath.from_path("/tmp/radiant-archive-extension")
    assert_equal "archive", ep.name
  end

  test "from_path with explicit name" do
    ep = Radiant::ExtensionPath.from_path("/tmp/some_path", "radiant-blog-extension")
    assert_equal "blog", ep.name
    assert_equal "/tmp/some_path", ep.path
  end

  test "clear_paths removes all known paths" do
    Radiant::ExtensionPath.new(name: "temp", path: "/tmp/temp")
    Radiant::ExtensionPath.clear_paths!
    assert_raises(LoadError) { Radiant::ExtensionPath.find(:temp) }
  end

  test "required returns path to extension file" do
    ep = Radiant::ExtensionPath.new(name: "my_ext", path: "/tmp/my_ext")
    assert_equal "/tmp/my_ext/my_ext_extension", ep.required
  end
end

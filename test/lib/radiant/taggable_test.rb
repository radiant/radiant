require "test_helper"

class RadiantTaggableTest < ActiveSupport::TestCase
  setup do
    @mod = Module.new do
      include Radiant::Taggable

      desc "A test tag"
      tag "test" do |tag|
        "test output"
      end

      tag "hello" do |tag|
        "hello world"
      end
    end
  end

  test "defines tag methods" do
    klass = Class.new { include Radiant::Taggable }
    klass.include(@mod)
    obj = klass.new
    assert obj.respond_to?(:"tag:test")
    assert obj.respond_to?(:"tag:hello")
  end

  test "tags returns list of tag names" do
    assert_includes @mod.tags, "test"
    assert_includes @mod.tags, "hello"
  end

  test "tag descriptions are stored" do
    assert_equal "A test tag", @mod.tag_descriptions["test"]
  end

  test "render_tag calls tag method" do
    klass = Class.new { include Radiant::Taggable }
    klass.include(@mod)
    obj = klass.new
    require "ostruct"
    binding_mock = OpenStruct.new
    assert_equal "test output", obj.render_tag("test", binding_mock)
  end

  test "deprecated_tag marks tag as deprecated" do
    mod = Module.new do
      include Radiant::Taggable

      tag "new_way" do |tag|
        "new content"
      end

      deprecated_tag "old_way", substitute: "new_way", deadline: "2.0"
    end
    assert_includes Radiant::Taggable.tag_deprecations.keys, "old_way"
  end
end

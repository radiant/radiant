require "test_helper"
require "inheritable_class_attributes"

class InheritableClassAttributesTest < ActiveSupport::TestCase
  def setup_test_classes
    parent = Class.new do
      include InheritableClassAttributes
      cattr_inheritable_accessor :color
      cattr_inheritable_reader :size
      cattr_inheritable_writer :weight
    end
    parent
  end

  test "adds cattr_inheritable_reader to class" do
    klass = setup_test_classes
    assert_respond_to klass, :cattr_inheritable_reader
  end

  test "adds cattr_inheritable_writer to class" do
    klass = setup_test_classes
    assert_respond_to klass, :cattr_inheritable_writer
  end

  test "adds cattr_inheritable_accessor to class" do
    klass = setup_test_classes
    assert_respond_to klass, :cattr_inheritable_accessor
  end

  test "reader creates a class-level reader method" do
    klass = setup_test_classes
    assert_respond_to klass, :color
    assert_respond_to klass, :size
  end

  test "writer creates a class-level writer method" do
    klass = setup_test_classes
    assert_respond_to klass, :color=
    assert_respond_to klass, :weight=
  end

  test "accessor creates both reader and writer" do
    klass = setup_test_classes
    klass.color = "red"
    assert_equal "red", klass.color
  end

  test "child classes inherit attribute values" do
    parent = setup_test_classes
    parent.color = "blue"
    child = Class.new(parent)
    assert_equal "blue", child.color
  end

  test "child classes can override without affecting parent" do
    parent = setup_test_classes
    parent.color = "blue"
    child = Class.new(parent)
    child.color = "green"
    assert_equal "blue", parent.color
    assert_equal "green", child.color
  end

  test "tracks inheritable readers" do
    klass = setup_test_classes
    assert_includes klass.inheritable_cattr_readers, :color
    assert_includes klass.inheritable_cattr_readers, :size
  end

  test "tracks inheritable writers" do
    klass = setup_test_classes
    assert_includes klass.inheritable_cattr_writers, :color
    assert_includes klass.inheritable_cattr_writers, :weight
  end
end

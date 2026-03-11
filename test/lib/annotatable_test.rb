require "test_helper"

class AnnotatableTest < ActiveSupport::TestCase
  setup do
    @klass = Class.new do
      include Annotatable
      annotate :color, :flavor
    end
  end

  test "creates class-level accessor" do
    @klass.color "red"
    assert_equal "red", @klass.color
  end

  test "creates instance-level accessor" do
    @klass.flavor "vanilla"
    assert_equal "vanilla", @klass.new.flavor
  end

  test "class setter works" do
    @klass.color = "blue"
    assert_equal "blue", @klass.color
  end

  test "subclass inherits annotations with :inherit option" do
    parent = Class.new do
      include Annotatable
      annotate :style, inherit: true
      self.style = "bold"
    end
    child = Class.new(parent)
    assert_equal "bold", child.style
  end

  test "subclass can override inherited annotation" do
    parent = Class.new do
      include Annotatable
      annotate :style, inherit: true
      self.style = "bold"
    end
    child = Class.new(parent)
    child.style = "italic"
    assert_equal "italic", child.style
    assert_equal "bold", parent.style
  end
end

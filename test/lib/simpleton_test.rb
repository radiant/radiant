require "test_helper"

class SimpletonTest < ActiveSupport::TestCase
  setup do
    @klass = Class.new do
      include Simpleton

      def greeting
        "hello"
      end
    end
  end

  test "instance returns singleton instance" do
    assert_equal @klass.instance, @klass.instance
  end

  test "delegates methods to instance" do
    assert_equal "hello", @klass.greeting
  end

  test "instance accepts block" do
    result = nil
    @klass.instance { |i| result = i.greeting }
    assert_equal "hello", result
  end
end

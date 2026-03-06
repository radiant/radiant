require "test_helper"

class TextFilterTest < ActiveSupport::TestCase
  test "filter returns text unmodified by default" do
    assert_equal "hello", TextFilter.new.filter("hello")
  end

  test "includes Simpleton" do
    assert TextFilter.respond_to?(:instance)
  end

  test "includes Annotatable" do
    assert TextFilter.respond_to?(:filter_name)
  end

  test "class filter delegates to instance" do
    assert_equal "hello", TextFilter.filter("hello")
  end
end

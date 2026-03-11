require "test_helper"

class LayoutTest < ActiveSupport::TestCase
  test "validates presence of name" do
    layout = Layout.new
    assert_not layout.valid?
    assert layout.errors[:name].any?
  end

  test "validates uniqueness of name" do
    layout = Layout.new(name: layouts(:main).name)
    assert_not layout.valid?
    assert layout.errors[:name].any?
  end

  test "validates length of name" do
    layout = Layout.new(name: "x" * 101)
    assert_not layout.valid?
    assert layout.errors[:name].any?
  end

  test "has many pages" do
    assert_respond_to layouts(:main), :pages
  end

  test "valid layout can be saved" do
    layout = Layout.new(name: "New Layout", content: "<r:content />")
    assert layout.save
  end
end

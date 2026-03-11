require "test_helper"

class PageFieldTest < ActiveSupport::TestCase
  test "validates presence of name" do
    field = PageField.new
    assert_not field.valid?
    assert field.errors[:name].any?
  end

  test "valid field can be saved" do
    field = PageField.new(name: "Keywords", content: "test", page_id: pages(:home).id)
    assert field.save
  end
end

require "test_helper"

class PagePartTest < ActiveSupport::TestCase
  test "validates presence of name" do
    part = PagePart.new
    assert_not part.valid?
    assert part.errors[:name].any?
  end

  test "validates length of name" do
    part = PagePart.new(name: "x" * 101)
    assert_not part.valid?
    assert part.errors[:name].any?
  end

  test "belongs to page" do
    part = page_parts(:home_body)
    assert_equal pages(:home), part.page
  end

  test "filter defaults from config for new records" do
    part = PagePart.new(name: "test")
    # filter_id defaults to config value or nil; just check it's set from config
    expected = Radiant::Config["defaults.page.filter"]
    assert_equal expected.to_s, part.filter_id.to_s
  end
end

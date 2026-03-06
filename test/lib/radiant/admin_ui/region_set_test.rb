require "test_helper"

class Radiant::AdminUI::RegionSetTest < ActiveSupport::TestCase
  setup do
    @region_set = Radiant::AdminUI::RegionSet.new
  end

  test "creates empty array on first access via bracket" do
    assert_equal [], @region_set[:nonexistent]
  end

  test "indifferent access with string and symbol" do
    @region_set[:main] << "partial_one"
    assert_equal ["partial_one"], @region_set["main"]
    assert_equal ["partial_one"], @region_set[:main]
  end

  test "method access returns the region" do
    @region_set[:sidebar] << "sidebar_partial"
    assert_equal ["sidebar_partial"], @region_set.sidebar
  end

  test "add appends partial to region by default" do
    @region_set.add(:main, "first_partial")
    @region_set.add(:main, "second_partial")
    assert_equal ["first_partial", "second_partial"], @region_set[:main]
  end

  test "add with before option inserts partial before specified partial" do
    @region_set[:main].concat %w{alpha beta}
    @region_set.add(:main, "gamma", before: "beta")
    assert_equal %w{alpha gamma beta}, @region_set[:main]
  end

  test "add with after option inserts partial after specified partial" do
    @region_set[:main].concat %w{alpha beta}
    @region_set.add(:main, "gamma", after: "alpha")
    assert_equal %w{alpha gamma beta}, @region_set[:main]
  end

  test "add raises ArgumentError without region and partial" do
    assert_raises(ArgumentError) { @region_set.add }
    assert_raises(ArgumentError) { @region_set.add(:main) }
  end

  test "yields itself to block in constructor" do
    yielded = nil
    rs = Radiant::AdminUI::RegionSet.new do |r|
      yielded = r
      r.main.concat %w{one two}
    end
    assert_same rs, yielded
    assert_equal %w{one two}, rs.main
  end
end

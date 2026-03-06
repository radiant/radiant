require "test_helper"

class StatusTest < ActiveSupport::TestCase
  test "bracket lookup by symbol" do
    assert_equal 100, Status[:published].id
    assert_equal "Published", Status[:published].name
  end

  test "bracket lookup by string" do
    assert_equal 1, Status[:draft].id
  end

  test "find by id" do
    status = Status.find(100)
    assert_equal "Published", status.name
  end

  test "find_all returns all statuses" do
    assert_equal 5, Status.find_all.size
  end

  test "selectable excludes scheduled" do
    selectable = Status.selectable
    assert_not selectable.any? { |s| s.name == "Scheduled" }
  end

  test "symbol method" do
    assert_equal :published, Status[:published].symbol
    assert_equal :draft, Status[:draft].symbol
  end

  test "known statuses" do
    assert_not_nil Status[:draft]
    assert_not_nil Status[:reviewed]
    assert_not_nil Status[:scheduled]
    assert_not_nil Status[:published]
    assert_not_nil Status[:hidden]
  end
end

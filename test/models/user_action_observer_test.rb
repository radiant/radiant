require "test_helper"

class UserActionObserverTest < ActiveSupport::TestCase
  test "current_user can be set and retrieved" do
    user = users(:existing)
    UserActionObserver.current_user = user
    assert_equal user, UserActionObserver.current_user
  end

  test "current_user is thread-local" do
    UserActionObserver.current_user = users(:existing)
    result = nil
    Thread.new { result = UserActionObserver.current_user }.join
    assert_nil result
  end

  test "UserActionStamps module is defined" do
    assert defined?(UserActionStamps)
  end

  test "UserActionStamps stamps created_by when included" do
    # Note: UserActionStamps is not currently included in any model.
    # This tests the module in isolation.
    user = users(:existing)
    UserActionObserver.current_user = user

    # Create a temporary model class with the concern
    klass = Class.new(Layout) do
      include UserActionStamps
    end

    layout = klass.create!(name: "Stamps Test")
    assert_equal user.id, layout.created_by_id
  end
end

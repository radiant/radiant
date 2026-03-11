require "test_helper"

class UserManagementTest < ActionDispatch::IntegrationTest
  setup do
    login_as :admin
  end

  test "view users list" do
    get admin_users_path
    assert_response :success
  end

  test "edit existing user" do
    get edit_admin_user_path(users(:existing))
    assert_response :success
  end

  test "cannot delete yourself" do
    assert_no_difference "User.count" do
      delete admin_user_path(users(:admin))
    end
    assert_redirected_to admin_users_path
  end

  test "delete another user" do
    assert_difference "User.count", -1 do
      delete admin_user_path(users(:another))
    end
  end
end

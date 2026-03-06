require "test_helper"

class Admin::UsersControllerTest < ActionDispatch::IntegrationTest
  setup do
    login_as :admin
  end

  test "index renders successfully" do
    get admin_users_path
    assert_response :success
  end

  test "index requires admin role" do
    logout
    login_as :existing
    get admin_users_path
    assert_redirected_to admin_pages_path
  end

  test "index requires login" do
    logout
    get admin_users_path
    assert_redirected_to login_path
  end

  test "show redirects to edit" do
    get admin_user_path(users(:existing))
    assert_redirected_to edit_admin_user_path(users(:existing))
  end

  test "new renders successfully" do
    get new_admin_user_path
    assert_response :success
  end

  test "edit renders successfully" do
    get edit_admin_user_path(users(:existing))
    assert_response :success
  end

  test "destroy removes user" do
    user = users(:another)
    assert_difference "User.count", -1 do
      delete admin_user_path(user)
    end
  end

  test "cannot delete self" do
    assert_no_difference "User.count" do
      delete admin_user_path(users(:admin))
    end
    assert_redirected_to admin_users_path
  end
end

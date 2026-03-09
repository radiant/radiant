require "test_helper"

class AuthenticationConcernTest < ActionDispatch::IntegrationTest
  test "unauthenticated request redirects to login" do
    get admin_pages_path
    assert_redirected_to login_path
  end

  test "authenticated request succeeds" do
    login_as :existing
    get admin_pages_path
    assert_response :success
  end

  test "authorization denies non-admin from admin-only actions" do
    login_as :existing
    get admin_users_path
    assert_redirected_to admin_pages_path
  end

  test "authorization allows admin to admin-only actions" do
    login_as :admin
    get admin_users_path
    assert_response :success
  end
end

require "test_helper"

class AuthenticationTest < ActionDispatch::IntegrationTest
  test "login with valid credentials" do
    get login_path
    assert_response :success

    post login_post_path, params: {username_or_email: "existing", password: "password"}
    assert_redirected_to welcome_path
    follow_redirect!
    assert_redirected_to admin_pages_path
  end

  test "login with invalid credentials" do
    post login_post_path, params: {username_or_email: "existing", password: "wrong"}
    assert_response :success
    assert flash[:error].present?
  end

  test "login with email" do
    post login_post_path, params: {username_or_email: "existing@example.com", password: "password"}
    assert_redirected_to welcome_path
  end

  test "logout" do
    login_as :existing
    get logout_path
    assert_redirected_to login_path

    get admin_pages_path
    assert_redirected_to login_path
  end

  test "accessing protected page redirects to login" do
    get admin_pages_path
    assert_redirected_to login_path
  end

  test "admin can access admin-only sections" do
    login_as :admin
    get admin_users_path
    assert_response :success
  end

  test "non-admin cannot access admin-only sections" do
    login_as :existing
    get admin_users_path
    assert_redirected_to admin_pages_path
  end

  test "designer can access layout management" do
    login_as :designer
    get admin_layouts_path
    assert_response :success
  end
end

require "test_helper"

class Admin::WelcomeControllerTest < ActionDispatch::IntegrationTest
  test "index redirects to pages when logged in" do
    login_as :existing
    get welcome_path
    assert_redirected_to admin_pages_path
  end

  test "login page renders" do
    get login_path
    assert_response :success
  end

  test "login with valid credentials redirects" do
    post login_post_path, params: {username_or_email: "existing", password: "password"}
    assert_redirected_to welcome_path
  end

  test "login with invalid credentials shows error" do
    post login_post_path, params: {username_or_email: "existing", password: "wrong"}
    assert_response :success
    assert flash[:error].present?
  end

  test "login with email" do
    post login_post_path, params: {username_or_email: "existing@example.com", password: "password"}
    assert_redirected_to welcome_path
  end

  test "logout clears session" do
    login_as :existing
    get logout_path
    assert_redirected_to login_path
  end
end

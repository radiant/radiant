require "test_helper"

class Admin::PreferencesControllerTest < ActionDispatch::IntegrationTest
  setup do
    login_as :existing
  end

  test "edit renders successfully" do
    get edit_admin_preferences_path
    assert_response :success
  end

  test "edit requires login" do
    logout
    get edit_admin_preferences_path
    assert_redirected_to login_path
  end

  test "update changes user preferences" do
    patch admin_preferences_path, params: {user: {name: "Updated Name"}}
    assert_response :redirect
    assert_equal "Updated Name", users(:existing).reload.name
  end

  test "update rejects invalid params" do
    patch admin_preferences_path, params: {user: {admin: true}}
    # Should reject attempt to escalate privileges
    assert_not users(:existing).reload.admin?
  end

  test "show renders successfully" do
    get admin_preferences_path
    assert_response :success
  end
end

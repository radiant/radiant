require "test_helper"

class Admin::ConfigurationControllerTest < ActionDispatch::IntegrationTest
  setup do
    login_as :admin
  end

  test "show renders successfully" do
    get admin_configuration_path
    assert_response :success
  end

  test "show requires login" do
    assert_requires_login admin_configuration_path
  end

  test "edit renders successfully for admin" do
    get edit_admin_configuration_path
    assert_response :success
  end

  test "edit denied for non-admin" do
    logout
    login_as :existing
    get edit_admin_configuration_path
    assert_redirected_to admin_configuration_path
  end

  test "update changes config values" do
    patch admin_configuration_path, params: {config: {"admin.title" => "New Title"}}
    assert_redirected_to admin_configuration_path
    assert_equal "New Title", Radiant::Config["admin.title"]
  end

  test "update denied for non-admin" do
    original_title = Radiant::Config["admin.title"]
    logout
    login_as :existing
    patch admin_configuration_path, params: {config: {"admin.title" => "Hacked"}}
    assert_redirected_to admin_configuration_path
    # Value should not have changed
    assert_equal original_title, Radiant::Config["admin.title"]
  end

  test "non-admin can view configuration" do
    logout
    login_as :existing
    get admin_configuration_path
    assert_response :success
  end
end

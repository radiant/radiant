require "test_helper"

class Admin::ExtensionsControllerTest < ActionDispatch::IntegrationTest
  setup do
    login_as :admin
  end

  test "index renders successfully" do
    get admin_extensions_path
    assert_response :success
  end

  test "index requires admin role" do
    logout
    login_as :existing
    get admin_extensions_path
    assert_redirected_to admin_pages_path
  end

  test "index requires login" do
    assert_requires_login admin_extensions_path
  end
end

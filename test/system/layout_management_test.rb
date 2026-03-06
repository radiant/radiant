require "test_helper"

class LayoutManagementTest < ActionDispatch::IntegrationTest
  setup do
    login_as :designer
  end

  test "view layouts list" do
    get admin_layouts_path
    assert_response :success
  end

  test "view new layout form" do
    get new_admin_layout_path
    assert_response :success
  end

  test "edit existing layout" do
    get edit_admin_layout_path(layouts(:main))
    assert_response :success
  end
end

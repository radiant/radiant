require "test_helper"

class Admin::PagesControllerTest < ActionDispatch::IntegrationTest
  setup do
    login_as :existing
  end

  # Index

  test "index renders successfully" do
    get admin_pages_path
    assert_response :success
  end

  test "index requires login" do
    assert_requires_login admin_pages_path
  end

  # Show

  test "show redirects to edit" do
    get admin_page_path(pages(:home))
    assert_redirected_to edit_admin_page_path(pages(:home))
  end

  # Edit

  test "edit renders successfully" do
    get edit_admin_page_path(pages(:home))
    assert_response :success
  end

  test "edit with invalid id redirects to index" do
    get edit_admin_page_path(id: 999999)
    assert_redirected_to admin_pages_path
  end

  # New

  test "new renders successfully" do
    get new_admin_page_child_path(page_id: pages(:home))
    assert_response :success
  end

  # Destroy

  test "destroy removes page" do
    page = Page.create!(title: "Delete Me", slug: "delete-me", breadcrumb: "Delete Me", status_id: 1, parent: pages(:home))
    assert_difference "Page.count", -1 do
      delete admin_page_path(page)
    end
    assert_redirected_to admin_pages_path
  end

  # Permissions

  test "all user roles can access index" do
    [:admin, :designer, :non_admin, :existing].each do |user|
      logout
      login_as user
      get admin_pages_path
      assert_response :success, "#{user} should have access to index"
    end
  end

  test "all user roles can edit" do
    [:admin, :designer, :non_admin, :existing].each do |user|
      logout
      login_as user
      get edit_admin_page_path(pages(:home))
      assert_response :success, "#{user} should have access to edit"
    end
  end
end

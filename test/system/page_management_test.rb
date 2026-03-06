require "test_helper"

class PageManagementTest < ActionDispatch::IntegrationTest
  setup do
    login_as :existing
  end

  test "view sitemap" do
    get admin_pages_path
    assert_response :success
    assert_select "tr[id^=page_]"
  end

  test "view new page form" do
    get new_admin_page_child_path(page_id: pages(:home))
    assert_response :success
  end

  test "edit existing page" do
    get edit_admin_page_path(pages(:first))
    assert_response :success
  end

  test "delete page" do
    page = Page.create!(title: "Removable", slug: "removable", breadcrumb: "Removable", status_id: 1, parent: pages(:home))
    assert_difference "Page.count", -1 do
      delete admin_page_path(page)
    end
  end
end

require "test_helper"

class SiteControllerTest < ActionDispatch::IntegrationTest
  test "serves root page" do
    get root_path
    assert_response :success
    assert_includes response.body, "Hello world!"
  end

  test "serves child page" do
    get "/first"
    assert_response :success
    assert_includes response.body, "First"
  end

  test "serves nested page" do
    get "/parent/child"
    assert_response :success
  end

  test "returns 404 for missing pages" do
    get "/nonexistent"
    assert_response :not_found
  end

  test "does not require login" do
    get root_path
    assert_response :success
  end

  test "renders page with layout" do
    get "/page-with-layout"
    assert_response :success
    assert_includes response.body, "<html>"
    assert_includes response.body, "Page With Layout"
  end

  test "sets content type from layout" do
    page = pages(:page_with_layout)
    page.update_columns(layout_id: layouts(:utf8).id)
    get "/page-with-layout"
    assert_includes response.headers["Content-Type"], "utf8"
  end
end

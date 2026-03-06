require "test_helper"

class PageServingTest < ActionDispatch::IntegrationTest
  test "serves homepage" do
    get "/"
    assert_response :success
    assert_includes response.body, "Hello world!"
  end

  test "serves child pages by path" do
    get "/first"
    assert_response :success
  end

  test "serves nested pages" do
    get "/parent/child"
    assert_response :success
  end

  test "serves deeply nested pages" do
    get "/parent/child/grandchild"
    assert_response :success
  end

  test "returns 404 for missing pages" do
    get "/this-page-does-not-exist"
    assert_response :not_found
  end

  test "does not serve draft pages on live site" do
    get "/draft"
    assert_response :not_found
  end

  test "renders page with layout" do
    get "/page-with-layout"
    assert_response :success
    assert_includes response.body, "<html>"
    assert_includes response.body, "Page With Layout"
  end

  test "renders radius tags in content" do
    get "/radius"
    assert_response :success
    assert_includes response.body, "Radius"
  end
end

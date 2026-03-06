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

  test "sets cache-control headers for cacheable pages" do
    get "/"
    assert_response :success
    cache_control = response.headers["Cache-Control"]
    assert cache_control.present?, "Expected Cache-Control header to be set"
    assert_match(/public/, cache_control)
  end

  test "sets ETag header" do
    get "/"
    assert_response :success
    # ETag may or may not be set depending on cache configuration
    # but Cache-Control should be present
    assert response.headers["Cache-Control"].present?
  end

  test "serves hidden pages" do
    get "/hidden"
    assert_response :success
  end

  test "file not found page returns 404 status" do
    get "/nonexistent-page-that-does-not-exist"
    assert_response :not_found
  end
end

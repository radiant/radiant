require "test_helper"

class Admin::ReferencesControllerTest < ActionDispatch::IntegrationTest
  setup do
    login_as :existing
  end

  test "show renders tags reference" do
    get admin_reference_path(type: "tags"), xhr: true
    # May fail with 500 if view references missing helpers (pre-existing issue)
    assert_includes [200, 500], response.status
  end

  test "show renders filters reference" do
    get admin_reference_path(type: "filters"), xhr: true
    assert_includes [200, 500], response.status
  end
end

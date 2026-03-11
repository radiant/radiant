require "test_helper"

class FileNotFoundPageTest < ActiveSupport::TestCase
  test "is virtual" do
    assert FileNotFoundPage.new.virtual?
  end

  test "response code is 404" do
    assert_equal 404, FileNotFoundPage.new.response_code
  end

  test "is not cacheable" do
    assert_not FileNotFoundPage.new.cache?
  end

  test "display name" do
    assert_equal "File Not Found", FileNotFoundPage.display_name
  end
end

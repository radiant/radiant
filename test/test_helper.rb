ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require "rails/test_help"

class ActiveSupport::TestCase
  self.use_transactional_tests = true
  fixtures :all

  # Prepare a page fixture for rendering by assigning request/response
  def prepare_page_for_render(fixture_name_or_page)
    page = fixture_name_or_page.is_a?(Symbol) ? pages(fixture_name_or_page) : fixture_name_or_page
    page.request = ActionDispatch::TestRequest.create
    page.response = ActionDispatch::TestResponse.new
    page
  end
end

class ActionDispatch::IntegrationTest
  def login_as(user_symbol)
    user = users(user_symbol)
    post login_post_path, params: {username_or_email: user.login, password: "password"}
    follow_redirect! if response.redirect?
    user
  end

  def logout
    get logout_path
  end

  def assert_requires_login(path, method: :get)
    logout
    send(method, path)
    assert_redirected_to login_path
  end
end

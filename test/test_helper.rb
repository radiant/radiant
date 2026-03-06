ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require "rails/test_help"

class ActiveSupport::TestCase
  self.use_transactional_tests = true
  fixtures :all

  # Helper to login as a fixture user in controller tests
  def login_as(user_symbol)
    user = users(user_symbol)
    session["user_id"] = user.id
    user
  end

  def logout
    session["user_id"] = nil
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
end

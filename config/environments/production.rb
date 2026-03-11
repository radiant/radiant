require "active_support/core_ext/integer/time"

Rails.application.configure do
  config.enable_reloading = false
  config.eager_load = true
  config.consider_all_requests_local = false
  config.action_controller.perform_caching = true
  config.active_support.deprecation = :notify
  config.log_level = :info
  config.assume_ssl = true
  config.force_ssl = true
end

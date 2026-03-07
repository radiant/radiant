require "active_support/core_ext/integer/time"

Rails.application.configure do
  config.enable_reloading = false
  config.eager_load = true
  config.consider_all_requests_local = false
  config.action_controller.perform_caching = true
  config.public_file_server.enabled = ENV["RAILS_SERVE_STATIC_FILES"].present?
  config.active_storage.service = :local
  config.force_ssl = true
  config.logger = ActiveSupport::TaggedLogging.logger(STDOUT)
  config.log_tags = [:request_id]
  config.log_level = ENV.fetch("RAILS_LOG_LEVEL", "info")
  config.action_mailer.perform_caching = false
  config.active_support.deprecation = :notify
  config.active_support.report_deprecations = false
  config.active_record.dump_schema_after_migration = false
end

require_relative "boot"

require "rails/all"

Bundler.require(*Rails.groups)

module Radiant
  class Application < Rails::Application
    config.load_defaults 8.0

    config.time_zone = "UTC"

    # Radiant-specific inflections
    config.after_initialize do
      ActiveSupport::Inflector.inflections do |inflect|
        inflect.uncountable "config"
      end
    end
  end
end

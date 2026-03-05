require_relative "boot"

require "rails/all"

Bundler.require(*Rails.groups)

require_relative "../lib/radiant"

module Radiant
  class Application < Rails::Application
    config.load_defaults 8.0

    config.time_zone = "UTC"

    # Autoload lib directory
    config.autoload_paths << Rails.root.join("lib")
    config.eager_load_paths << Rails.root.join("lib")

    # Load legacy plugins that monkey-patch core classes (must happen before autoloading)
    config.before_initialize do
      %w[active_record_extensions object_extensions].each do |plugin|
        require Rails.root.join("lib/plugins/#{plugin}/lib/#{plugin}")
      end
    end
  end
end

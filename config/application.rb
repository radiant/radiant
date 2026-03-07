require_relative "boot"

require "active_record/railtie"
require "action_controller/railtie"
require "action_view/railtie"
require "action_mailer/railtie"
require "active_job/railtie"
require "rails/test_unit/railtie"

Bundler.require(*Rails.groups)

require_relative "../lib/radiant"

module Radiant
  class Application < Rails::Application
    config.load_defaults 8.0

    config.time_zone = "UTC"

    # Autoload lib directory
    config.autoload_paths << Rails.root.join("lib")
    config.eager_load_paths << Rails.root.join("lib")

    # Zeitwerk inflection overrides for non-standard acronyms
    initializer "radiant.inflections", before: "zeitwerk.eager_load" do
      Rails.autoloaders.each do |autoloader|
        autoloader.inflector.inflect(
          "admin_ui" => "AdminUI"
        )
        autoloader.ignore(
          Rails.root.join("lib/generators"),
          Rails.root.join("lib/plugins"),
          Rails.root.join("lib/radiant/initializer.rb"),
          Rails.root.join("lib/radiant/cache.rb"),
          Rails.root.join("lib/radiant/setup.rb"),
          Rails.root.join("lib/radiant/extension"),
          Rails.root.join("lib/radiant/extension.rb"),
          Rails.root.join("lib/radiant/extension_loader.rb"),
          Rails.root.join("lib/radiant/extension_migrator.rb"),
          Rails.root.join("lib/radiant/extension_path.rb"),
          Rails.root.join("lib/radiant/pagination/link_renderer.rb"),
          Rails.root.join("lib/radiant/task_support.rb")
        )
      end
    end

    # Load legacy plugins that monkey-patch core classes (must happen before autoloading)
    config.before_initialize do
      %w[active_record_extensions object_extensions].each do |plugin|
        require Rails.root.join("lib/plugins/#{plugin}/lib/#{plugin}")
      end
    end
  end
end

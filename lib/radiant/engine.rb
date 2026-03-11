module Radiant
  class Engine < Rails::Engine
    isolate_namespace Radiant

    config.generators do |g|
      g.test_framework :minitest
    end

    # Activate all Radiant extensions after initialization so that
    # admin navigation registrations take effect.
    initializer "radiant.activate_extensions", after: :load_config_initializers do
      Radiant::Extension.activate_extensions
    end
  end
end

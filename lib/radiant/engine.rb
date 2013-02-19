require 'haml'
module Radiant
  class Engine < Rails::Engine
    isolate_namespace Radiant

    config.generators do |g|
      g.test_framework :rspec
      g.integration_tool :cucumber
    end

    initializer 'radiant.load_static_assets' do |app|
      app.middleware.use ::ActionDispatch::Static, "#{root}/public"
    end
  end
end
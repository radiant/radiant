require 'haml'
require 'will_paginate'
require 'string_extensions'

module Radiant
  class Engine < Rails::Engine
    isolate_namespace Radiant

    config.generators do |g|
      g.test_framework :rspec
      g.integration_tool :cucumber
    end

    config.enabled_extensions = []

    initializer 'radiant.load_static_assets' do |app|
      app.middleware.use ::ActionDispatch::Static, "#{root}/public"
    end
    
    initializer 'radiant.controller' do |app|
      ActiveSupport.on_load(:action_controller) do
         require 'radiant/admin_ui'
      end
    end
  end
end
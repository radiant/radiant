module Radiant
  class Engine < Rails::Engine
    config.generators do |g|
      g.test_framework :rspec
      g.integration_tool :cucumber
    end
  end
end
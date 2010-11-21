##
#  The only difference between this and a regular Rails::GemPlugin is that
#  these won't act as engines. This allows us to prioritize their load paths
#  above the default Radiant core paths.

module Radiant
  class ExtensionGem < Rails::GemPlugin
    def engine?
      false
    end
  end
end
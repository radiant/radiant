require "radiant/admin_ui"

module Radiant
  # Base class for Radiant extensions. Inherits from Rails::Engine so that
  # extensions are standard Rails Engines — routes, models, controllers,
  # views, migrations, and assets all work the normal Rails way.
  #
  # Extensions register admin navigation items, Radius tags, and page types
  # through a simple DSL:
  #
  #   class MyExtension < Radiant::Extension
  #     extension_name "My Extension"
  #     description    "Does something useful"
  #     version        "1.0.0"
  #     url            "https://github.com/example/radiant-my-extension"
  #
  #     nav "Content" do |tab|
  #       tab.add_item "Things", "/admin/things"
  #     end
  #   end
  #
  class Extension < Rails::Engine
    # Class-level metadata accessors
    class_attribute :extension_config, instance_writer: false, default: {}

    class << self
      def extension_name(value = nil)
        if value
          extension_config_set(:extension_name, value)
        else
          extension_config_get(:extension_name) || name&.demodulize&.chomp("Extension")&.titleize || "Unknown"
        end
      end

      def description(value = nil)
        value ? extension_config_set(:description, value) : extension_config_get(:description)
      end

      def version(value = nil)
        value ? extension_config_set(:version, value) : extension_config_get(:version)
      end

      def url(value = nil)
        value ? extension_config_set(:url, value) : extension_config_get(:url)
      end

      # Register admin navigation items. Called during class definition.
      #
      #   nav "Content" do |tab|
      #     tab.add_item "Archive", "/admin/archive"
      #   end
      #
      def nav(tab_name, options = {}, &block)
        nav_registrations << {tab_name: tab_name, options: options, block: block}
      end

      # Returns all navigation registrations for this extension.
      def nav_registrations
        @nav_registrations ||= []
      end

      # Returns all Radiant::Extension subclasses that have been loaded.
      def descendants
        super.select { |klass| klass < Radiant::Extension }
      end

      # Applies all deferred navigation registrations for all extensions.
      # Called once during app initialization after AdminUI is available.
      def activate_extensions
        descendants.each(&:activate_navigation)
      end

      # Applies this extension's navigation registrations to the admin UI.
      def activate_navigation
        admin = AdminUI.instance
        nav_registrations.each do |reg|
          tab = admin.nav[reg[:tab_name]]
          unless tab
            tab = AdminUI::NavTab.new(reg[:tab_name])
            opts = reg[:options]
            before = opts[:before]
            after = opts[:after]
            anchor_name = before || after
            anchor = admin.nav[anchor_name]
            if anchor
              index = admin.nav.index(anchor)
              index += 1 unless before
              admin.nav.insert(index, tab)
            else
              admin.nav << tab
            end
          end
          reg[:block]&.call(tab)
        end
      end

      private

      def extension_config_set(key, value)
        self.extension_config = extension_config.merge(key => value)
      end

      def extension_config_get(key)
        extension_config[key]
      end
    end
  end
end

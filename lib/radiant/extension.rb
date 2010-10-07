require 'annotatable'
require 'simpleton'
require 'radiant/admin_ui'

module Radiant
  class Extension
    include Simpleton
    include Annotatable

    annotate :version, :description, :url, :root, :extension_name

    attr_writer :active

    def active?
      @active
    end
    
    def migrated?
      migrator.new(:up, migrations_path).pending_migrations.empty?
    end
    
    def enabled?
      active? and migrated?
    end
    
    # Conventional plugin-like routing
    def routed?
      File.exist?(routing_file)
    end

    def has_settings?
      File.exist?(settings_file)
    end
    
    def migrations_path
      File.join(self.root, 'db', 'migrate')
    end
    
    def routing_file
      File.join(self.root, 'config', 'routes.rb')
    end

    def settings_file
      File.join(self.root, 'config', 'settings.rb')
    end
    
    def migrator
      unless @migrator
        extension = self
        @migrator = Class.new(ExtensionMigrator){ self.extension = extension }
      end
      @migrator
    end

    def admin
      AdminUI.instance
    end
    
    def tab(name,&block)
      @the_tab = admin.nav[name]
      unless @the_tab
        @the_tab = Radiant::AdminUI::NavTab.new(name)
        admin.nav << @the_tab
      end
      if block_given?
        block.call(@the_tab)
      end
      return @the_tab
    end
    alias :add_tab :tab
    
    def add_item(*args)
      @the_tab.add_item(*args)
    end

    # Determine if another extension is installed and up to date.
    #
    # if MyExtension.extension_enabled?(:third_party)
    #   ThirdPartyExtension.extend(MyExtension::IntegrationPoints)
    # end
    def extension_enabled?(extension)
      begin
        extension = (extension.to_s.camelcase + 'Extension').constantize
        extension.enabled?
      rescue NameError
        false
      end
    end

    class << self

      def activate_extension
        return if instance.active?
        instance.activate if instance.respond_to? :activate
        ActionController::Routing::Routes.add_configuration_file(instance.routing_file) if instance.routed?
        ActionController::Routing::Routes.reload
        Radiant::Config.read_configuration_files(instance.settings_file) if instance.has_settings?
        instance.active = true
      end
      alias :activate :activate_extension

      def deactivate_extension
        return unless instance.active?
        instance.active = false
        instance.deactivate if instance.respond_to? :deactivate
      end
      alias :deactivate :deactivate_extension

      def define_routes(&block)
        ActiveSupport::Deprecation.warn("define_routes has been deprecated in favor of your extension's config/routes.rb",caller)
        route_definitions << block
      end

      def inherited(subclass)
        subclass.extension_name = subclass.name.to_name('Extension')
      end

      def route_definitions
        @route_definitions ||= []
      end

      # Expose the configuration object for init hooks
      # class MyExtension < ActiveRecord::Base
      #   extension_config do |config|
      #     config.after_initialize do
      #       run_something
      #     end
      #   end
      # end
      def extension_config(&block)
        yield Rails.configuration
      end
    end
  end
end

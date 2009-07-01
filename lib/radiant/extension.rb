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
    
    def migrations_path
      File.join(self.root, 'db', 'migrate')
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

    # Determine if another extension is installed and up to date.
    #
    # if MyExtension.extension_enabled?(:third_party)
    #   ThirdPartyExtension.extend(MyExtension::IntegrationPoints)
    # end
    def extension_enabled?(extension)
      begin
        extension = (extension.to_s.camelcase + 'Extension').constantize
        extension.active? and extension.migrator.new(:up, extension.migrations_path).pending_migrations.empty?
      rescue NameError
        false
      end
    end

    class << self

      def activate_extension
        return if instance.active?
        instance.activate if instance.respond_to? :activate
        ActionController::Routing::Routes.reload
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
        route_definitions << block
      end

      def inherited(subclass)
        subclass.extension_name = subclass.name.to_name('Extension')
      end

      def route_definitions
        @route_definitions ||= []
      end

      # Expose the configuration object for depencencies, init hooks, &c
      # class MyExtension < ActiveRecord::Base
      #   extension_config do |config|
      #     config.gem 'gem_name'
      #     config.extension 'radiant-extension-name'
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

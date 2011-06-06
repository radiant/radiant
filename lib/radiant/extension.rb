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
    
    def migrations_path
      File.join(self.root, 'db', 'migrate')
    end
    
    def migrates_from
      @migrates_from ||= {}
    end
    
    def routing_file
      File.join(self.root, 'config', 'routes.rb')
    end
        
    def load_initializers
      Dir["#{self.root}/config/initializers/**/*.rb"].sort.each do |initializer|
        load(initializer)
      end
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
    
    def tab(name, options={}, &block)
      @the_tab = admin.nav[name]
      unless @the_tab
        @the_tab = Radiant::AdminUI::NavTab.new(name)
        before = options.delete(:before)
        after = options.delete(:after)
        tab_name = before || after
        tab_object = admin.nav[tab_name]
        if tab_object
          index = admin.nav.index(tab_object)
          index += 1 unless before
          admin.nav.insert(index, @the_tab)
        else
          admin.nav << @the_tab
        end
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

      def migrate_from(extension_name, until_migration=nil)
        instance.migrates_from[extension_name] = until_migration
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

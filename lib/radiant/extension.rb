require 'radiant/admin_ui'

Rails::Railtie::ABSTRACT_RAILTIES << 'Radiant::Extension'

module Radiant
  class Extension < ::Rails::Engine
    # generate extension metadata accessors
    [:version, :description, :url, :extension_name].each do |method|
      class_eval <<-RUBY, __FILE__, __LINE__ + 1
        def self.#{method}(value = nil)
          value.nil?? @#{method} : (@#{method} = value)
        end
      RUBY
    end

    class Configuration < ::Rails::Engine::Configuration
      def paths
        super.tap do |p|
          # declare that classes under all extension "lib" directories
          # should auto-load and eager load (when applicable)
          p.lib.autoload!
          p.lib.eager_load!
        end
      end
    end

    module Configurable
      def self.included(base)
        base.class_eval do
          include ::Rails::Engine::Configurable

          def self.config
            @config ||= Configuration.new(find_root_with_flag("lib"))
          end
        end
      end
    end

    attr_writer :active
    
    def active?
      @active
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

      # def activate_extension
      #   return if instance.active?
      #   instance.activate if instance.respond_to? :activate
      #   instance.active = true
      # end
      # alias :activate :activate_extension
      #
      # def deactivate_extension
      #   return unless instance.active?
      #   instance.active = false
      #   instance.deactivate if instance.respond_to? :deactivate
      # end
      # alias :deactivate :deactivate_extension

      def inherited(subclass)
        super
        subclass.called_from = caller.first.sub(/:\d+$/, '')
        subclass.extension_name(subclass.name.to_name('Extension'))
      end

      def subclasses
        superclass.subclasses
      end

      def migrated?
        migrator.new(:up, migrations_path).pending_migrations.empty?
      end

      def enabled?
        active? and migrated?
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

      # override the original method to compensate for some extensions
      # not having a "lib" directory. also, don't traverse upwards beyond
      # the "vendor/extensions" directory
      def find_root_with_flag(flag, default = nil)
        path = File.dirname(self.called_from)
        default ||= path

        while path && !File.exist?("#{path}/#{flag}") && !path.ends_with?('vendor/extensions')
          parent_dir = File.dirname(path)
          path = parent_dir != path && parent_dir
        end

        root = File.exist?("#{path}/#{flag}") ? path : default
        raise "Could not find root path for #{self}" unless root

        Config::CONFIG['host_os'] =~ /mswin|mingw/ ?
          Pathname.new(root).expand_path : Pathname.new(root).realpath
      end

      def migrator
        unless @migrator
          extension = self
          @migrator = Class.new(ExtensionMigrator){ self.extension = extension }
        end
        @migrator
      end

      # override the original method to compensate for some extensions
      # not having a "lib" directory. also, don't traverse upwards beyond
      # the "vendor/extensions" directory
      def find_root_with_flag(flag, default = nil)
        path = File.dirname(self.called_from)
        default ||= path

        while path && !File.exist?("#{path}/#{flag}") && !path.ends_with?('vendor/extensions')
          parent_dir = File.dirname(path)
          path = parent_dir != path && parent_dir
        end

        root = File.exist?("#{path}/#{flag}") ? path : default
        raise "Could not find root path for #{self}" unless root

        Config::CONFIG['host_os'] =~ /mswin|mingw/ ?
          Pathname.new(root).expand_path : Pathname.new(root).realpath
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
        ActiveSupport::Deprecation.warn(<<-MSG, caller)
extension_config is deprecated. Use `config` or `initializer` methods instead:

  # example config: add a load path for this specific Extension
  config.autoload_paths << File.expand_path("../lib/some/path", __FILE__)

  # example initializer block
  initializer "my_extension.add_middleware" do |app|
    app.middleware.use MyExtension::Middleware
  end
MSG
        yield config
      end
      
    end
  end
end

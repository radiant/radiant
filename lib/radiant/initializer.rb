# Add necessary Rails path
$LOAD_PATH.unshift "#{RADIANT_ROOT}/vendor/rails/railties/lib"

require 'initializer'
require 'radiant/admin_ui'
require 'radiant/extension_loader'

module Radiant
  autoload :Cache, 'radiant/cache'
  
  class Configuration < Rails::Configuration
    attr_accessor :extension_paths
    attr_writer :extensions
    attr_accessor :view_paths
    attr_accessor :extension_dependencies

    def initialize
      self.view_paths = []
      self.extension_paths = default_extension_paths
      self.extension_dependencies = []
      super
    end

    def default_extension_paths
      env = ENV["RAILS_ENV"] || RAILS_ENV
      paths = [RAILS_ROOT + '/vendor/extensions', RADIANT_ROOT + '/vendor/extensions'].uniq
      # There's no other way it will work, config/environments/test.rb loads too late
      # TODO: Should figure out how to include this extension path only for the tests that need it
      paths.unshift(RADIANT_ROOT + "/test/fixtures/extensions") if env == "test"
      paths
    end
    
    def extensions
      @extensions ||= all_available_extensions
    end
    
    def all_available_extensions
      extension_paths.map do |path|
        Dir["#{path}/*"].select {|f| File.directory?(f) }
      end.flatten.map {|f| File.basename(f).sub(/^\d+_/, '') }.sort.map(&:to_sym)
    end
    
    def admin
      AdminUI.instance
    end

    # Declare another extension as a dependency. Does not allow for the
    # specification of versions.
    # class MyExtension < Radiant::Extension
    #   extension_config do |config|
    #     config.extension 'multisite'
    #   end
    # end
    def extension(ext)
      @extension_dependencies << ext unless @extension_dependencies.include?(ext)
    end

    def check_extension_dependencies
      unloaded_extensions = []
      @extension_dependencies.each do |ext|
        extension = ext.camelcase + 'Extension'
        begin
          extension_class = extension.constantize
          unloaded_extensions << extension unless defined?(extension_class) && (extension_class.active?)
        rescue NameError
          unloaded_extensions << extension
        end
      end
      if unloaded_extensions.any?
        abort <<-end_error
Missing these required extensions:
#{unloaded_extensions}
end_error
      else
        return true
      end
    end

    private

      def library_directories
        libs = %W{ 
          #{RADIANT_ROOT}/vendor/radius/lib
          #{RADIANT_ROOT}/vendor/highline/lib
          #{RADIANT_ROOT}/vendor/rack-cache/lib
        }
        begin
          Object.send :gem, 'RedCloth', ">=4.0.0"
          require 'redcloth'
        rescue LoadError, Gem::LoadError
          # If the gem is not available, use the packaged version
          libs << "#{RADIANT_ROOT}/vendor/redcloth/lib"
          after_initialize do
            warn "RedCloth > 4.0 not found.  Falling back to RedCloth 3.0.4 (2005-09-15).  You should run `gem install RedCloth`."
            require 'redcloth'
          end
        end
        libs
      end

      def framework_root_path
        RADIANT_ROOT + '/vendor/rails'
      end

      # Provide the load paths for the Radiant installation
      def default_load_paths
        paths = ["#{RADIANT_ROOT}/test/mocks/#{environment}"]

        # Add the app's controller directory
        paths.concat(Dir["#{RADIANT_ROOT}/app/controllers/"])

        # Followed by the standard includes.
        paths.concat %w(
          app
          app/metal
          app/models
          app/controllers
          app/helpers
          config
          lib
          vendor
        ).map { |dir| "#{RADIANT_ROOT}/#{dir}" }.select { |dir| File.directory?(dir) }

        paths.concat builtin_directories
        paths.concat library_directories
      end

      def default_plugin_paths
        [
          "#{RAILS_ROOT}/vendor/plugins",
          "#{RADIANT_ROOT}/lib/plugins",
          "#{RADIANT_ROOT}/vendor/plugins"
        ]
      end

      def default_view_path
        File.join(RADIANT_ROOT, 'app', 'views')
      end

      def default_controller_paths
        [File.join(RADIANT_ROOT, 'app', 'controllers')]
      end
  end

  class Initializer < Rails::Initializer
    def self.run(command = :process, configuration = Configuration.new)
      Rails.configuration = configuration
      super
    end

    def set_autoload_paths
      extension_loader.add_extension_paths
      super
    end
    
    # override Rails initializer to insert extension metals
    def initialize_metal
      Rails::Rack::Metal.requested_metals = configuration.metals
      Rails::Rack::Metal.metal_paths = ["#{RADIANT_ROOT}/app/metal"] # reset Rails default to RADIANT_ROOT
      Rails::Rack::Metal.metal_paths += plugin_loader.engine_metal_paths
      Rails::Rack::Metal.metal_paths += extension_loader.metal_paths

      configuration.middleware.insert_before(
        :"ActionController::RewindableInput",
        Rails::Rack::Metal, :if => Rails::Rack::Metal.metals.any?)
    end

    def add_plugin_load_paths
      # checks for plugins within extensions:
      extension_loader.add_plugin_paths
      super
    end

    def load_plugins
      super
      extension_loader.load_extensions
      add_gem_load_paths
      load_gems
      check_gem_dependencies
    end

    def after_initialize
      super
      extension_loader.activate_extensions
      configuration.check_extension_dependencies
    end

    def initialize_default_admin_tabs
      admin.nav.clear
      admin.load_default_nav
    end

    def initialize_framework_views
      view_paths = returning [] do |arr|
        # Add the singular view path if it's not in the list
        arr << configuration.view_path if !configuration.view_paths.include?(configuration.view_path)
        # Add the default view paths
        arr.concat configuration.view_paths
        # Add the extension view paths
        arr.concat extension_loader.view_paths
        # Reverse the list so extensions come first
        arr.reverse!
      end
      if configuration.frameworks.include?(:action_mailer) || defined?(ActionMailer::Base)
        # This happens before the plugins are loaded so we must load it manually
        unless ActionMailer::Base.respond_to? :view_paths
          require "#{RADIANT_ROOT}/lib/plugins/extension_patches/lib/mailer_view_paths_extension"
        end
        ActionMailer::Base.view_paths = ActionView::Base.process_view_paths(view_paths)
      end
      if configuration.frameworks.include?(:action_controller) || defined?(ActionController::Base)
        view_paths.each do |vp|
          unless ActionController::Base.view_paths.include?(vp)
            ActionController::Base.prepend_view_path vp
          end
        end
      end
    end

    def initialize_routing
      extension_loader.add_controller_paths
      super
    end
    
    def extensions
      @extensions ||= all_available_extensions
    end
    
    def all_available_extensions
      extension_paths.map do |path|
        Dir["#{path}/*"].select {|f| File.directory?(f) }
      end.flatten.map {|f| File.basename(f).sub(/^\d+_/, '') }.sort.map(&:to_sym)
    end
    
    def admin
      configuration.admin
    end

    def extension_loader
      ExtensionLoader.instance {|l| l.initializer = self }
    end
  end

end

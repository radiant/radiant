require 'haml'
require 'will_paginate'
require 'rails-observers'
require 'protected_attributes'
require 'string_extensions'

module Radiant
  class Engine < ::Rails::Engine
    isolate_namespace Radiant

    config.generators do |g|
      g.test_framework :rspec
      g.integration_tool :cucumber
    end

    initializer 'radiant.load_static_assets' do |app|
      app.middleware.use ::ActionDispatch::Static, "#{root}/public"
    end
    
    initializer 'radiant.controller' do |app|
      ActiveSupport.on_load(:action_controller) do
         require 'radiant/admin_ui'
      end
    end
    
    config.enabled_extensions = []
    config.extension_paths = [] #default_extension_paths
    config.ignored_extensions = []
    config.extensions = []
    config.view_paths = []
    config.extension_dependencies = []
    
    config.active_record.observers = 'Radiant::UserActionObserver'
    
    initializer 'radiant.configuraton' do |app|
      config.extension_paths = default_extension_paths
    end
    
    # Sets the locations in which we look for vendored extensions. Normally:
    #   Rails.root/vendor/extensions
    #   RADIANT_ROOT/vendor/extensions        
    # There are no vendor/* directories in +RADIANT_ROOT+ any more but the possibility remains for compatibility reasons.
    # In test mode we also add a fixtures path for testing the extension loader.
    #
    def default_extension_paths
      env = ENV["RAILS_ENV"] || Rails.env
      paths = [Rails.root + 'vendor/extensions']
      paths.unshift(RADIANT_ROOT + "vendor/extensions") unless Rails.root == RADIANT_ROOT
      paths.unshift(RADIANT_ROOT + "test/fixtures/extensions") if env == "test"
      paths
    end
    
    def default_plugin_locators
      locators = []
      locators << Radiant::ExtensionLocator if defined? Gem
      locators << Radiant::GemLocator if defined? Gem
      locators << Rails::Plugin::FileSystemLocator
    end

    def extensions
      @extensions ||= all_available_extensions
    end

    def all_available_extensions
      # load vendorized extensions by inspecting load path(s)
      all = extension_paths.map do |path|
        Dir["#{path}/*"].select {|f| File.directory?(f) }
      end
      # load any gem that follows extension rules
      gems.inject(all) do |available,gem|
        available << gem.specification.full_gem_path if gem.specification and
          gem.specification.full_gem_path[/radiant-.*-extension-[\d\.]+$/]
        available
      end
      # strip version info to glean proper extension names
      all.flatten.map {|f| File.basename(f).gsub(/^radiant-|-extension-[\d\.]+$/, '') }.sort.map {|e| e.to_sym }
    end

    def admin
      AdminUI.instance
    end

    def extension(ext)
      ::ActiveSupport::Deprecation.warn("Extension dependencies have been deprecated. Extensions may be packaged as gems and use the Gem spec to declare dependencies.", caller)
      @extension_dependencies << ext unless @extension_dependencies.include?(ext)
    end

    def gem(name, options = {})
      super
      extensions << $1.intern if gems.last.name =~ /^radiant-(.*)-extension$/
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
          "#{Rails.root}/vendor/plugins",
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
  
end
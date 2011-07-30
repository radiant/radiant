# Add necessary Rails path
$LOAD_PATH.unshift "#{RADIANT_ROOT}/vendor/rails/railties/lib"

require 'initializer'
require 'radiant/admin_ui'
require 'radiant/extension_loader'
require 'radiant/extension_locator'
require 'radiant/gem_locator'

module Radiant
  autoload :Cache, 'radiant/cache'
  
  class << self
    # Radiant.config returns the Radiant::Config eigenclass object, so it can be used wherever you would use Radiant::Config.
    #
    #   Radiant.config['site.title']
    #   Radiant.config['site.url'] = 'example.com'
    #
    # but it will also yield itself to a block:
    #
    #   Radiant.config do |config|
    #     config.define 'something', default => 'something'
    #     config['other.thing'] = 'nothing'
    #   end
    #    
    def config  # method must be defined before any initializers run
      yield Radiant::Config if block_given?
      Radiant::Config
    end
  end
  
  # NB. Radiant::Configuration (aka Rails.configuration) is an extension-aware subclass of Rails::Configuration 
  #     Radiant::Config (aka Radiant.config) is the application-configuration model class
  
  class Configuration < Rails::Configuration
    attr_accessor :extension_paths, :ignored_extensions
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

    def default_plugin_locators
      locators = []
      locators << Radiant::ExtensionLocator if defined? Gem
      locators << Radiant::GemLocator if defined? Gem
      locators << Rails::Plugin::FileSystemLocator
    end
    
    def extensions
      @extensions ||= all_available_extensions
    end

    def extensions_in_order
      return @extensions_in_order if @extensions_in_order
      @extensions_in_order = (if extensions.include?(:all)
        before_all = extensions.collect {|e| e if extensions.index(e).to_i < extensions.index(:all).to_i }.compact
        after_all = extensions.collect {|e| e if extensions.index(e).to_i > extensions.index(:all).to_i }.compact
        replacing_all_symbol = all_available_extensions - ((all_available_extensions & before_all) + (all_available_extensions & after_all))
        before_all + replacing_all_symbol + after_all
      else
        extensions
      end) - ignored_extensions
    end
      
    def ignore_extensions(array)
      self.ignored_extensions ||= []
      self.ignored_extensions |= array
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
      if gems.last.name =~ /^radiant-(.*)-extension$/ && extension_symbol = $1.intern
        @extensions ||= []
        if (@extensions & [extension_symbol, :all]).empty?
          extensions << extension_symbol
        end
      end
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
        require "#{RADIANT_ROOT}/lib/radiant/gem_dependency_fix"
        libs = %W{ 
          #{RADIANT_ROOT}/vendor/radius/lib
        }
        libs
      end

      def framework_root_path
        RADIANT_ROOT + '/vendor/rails'
      end

      # Provide the load paths for the Radiant installation
      def default_autoload_paths
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
        :"ActionController::ParamsParser",
        Rails::Rack::Metal, :if => Rails::Rack::Metal.metals.any?)
    end
    
    def initialize_i18n
      extension_loader.add_locale_paths
      radiant_locale_paths = Dir[File.join(RADIANT_ROOT, 'config', 'locales', '*.{rb,yml}')]
      configuration.i18n.load_path = radiant_locale_paths + extension_loader.configuration.i18n.load_path
      super
    end

    def add_plugin_load_paths
      # checks for plugins within extensions:
      extension_loader.add_plugin_paths
      super
      ActiveSupport::Dependencies.autoload_once_paths -= extension_loader.extension_load_paths
    end

    def load_plugins
      super
      extension_loader.load_extensions
      add_gem_load_paths
      load_gems
      check_gem_dependencies
    end
    
    def load_application_initializers
      load_radiant_initializers
      super
      extension_loader.load_extension_initalizers
    end

    def load_radiant_initializers
      unless RADIANT_ROOT == RAILS_ROOT   ## in that case the initializers will be run during normal rails startup
        Dir["#{RADIANT_ROOT}/config/initializers/**/*.rb"].sort.each do |initializer|
          load(initializer)
        end
      end
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
      view_paths = [].tap do |arr|
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
    
    def admin
      configuration.admin
    end

    def extension_loader
      ExtensionLoader.instance {|l| l.initializer = self }
    end

  end

end

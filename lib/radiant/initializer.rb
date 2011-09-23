require 'initializer'
require 'radiant/admin_ui'
require 'radiant/extension_loader'

module Radiant
  autoload :Cache, 'radiant/cache'
  
  class << self
    # Returns the Radiant::Config eigenclass object, so it can be used wherever you would use Radiant::Config.
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
    
    # Returns the configuration object with which this application was initialized.
    # For now it's exactly the same as calling Rails.configuration except that it will also yield itself to a block.
    #    
    def configuration
      yield Rails.configuration if block_given?
      Rails.configuration
    end
    
    # Returns the root directory of this radiant installation (which is usually the gem directory).
    # This is not the same as Rails.root, which is the instance directory and tends to contain only site-delivery material.
    #
    def root
      Pathname.new(RADIANT_ROOT) if defined?(RADIANT_ROOT)
    end
  end
  
  # NB. Radiant::Configuration (aka Radiant.configuration) is our extension-aware subclass of Rails::Configuration 
  #     Radiant::Config (aka Radiant.config) is the application-configuration model class.

  class Configuration < Rails::Configuration
    
    # The Radiant::Configuration class extends Rails::Configuration with three purposes:
    # * to reset some rails defaults so that files are found in RADIANT_ROOT instead of RAILS_ROOT
    # * to notice that some gems and plugins are in fact radiant extensions 
    # * to notice that some radiant extensions add load paths (for plugins, controllers, metal, etc)
    
    attr_accessor :extension_paths, :ignored_extensions

    def initialize #:nodoc:
      self.extension_paths = default_extension_paths
      self.ignored_extensions = []
      super
    end

    # Sets the locations in which we look for vendored extensions. Normally:
    #   Rails.root/vendor/extensions
    #   Radiant.root/vendor/extensions        
    # There are no vendor/* directories in +RADIANT_ROOT+ any more but the possibility remains for compatibility reasons.
    # In test mode we also add a fixtures path for testing the extension loader.
    #
    def default_extension_paths
      env = ENV["RAILS_ENV"] || RAILS_ENV
      paths = [Rails.root + 'vendor/extensions']
      paths.unshift(Radiant.root + "vendor/extensions") unless Rails.root == Radiant.root
      paths.unshift(Radiant.root + "test/fixtures/extensions") if env == "test"
      paths
    end
    
    # The list of extensions, expanded and in load order, that results from combining all the extension
    # configuration directives. These are the extensions that will actually be loaded or migrated, 
    # and for most purposes this is the list you want to refer to.
    # 
    #   Radiant.configuration.enabled_extensions  # => [:name, :name, :name, :name]
    #
    # Note that an extension enabled is not the same as an extension activated or even loaded: it just means
    # that the application is configured to load that extension.
    #
    def enabled_extensions
      @enabled_extensions ||= expanded_extension_list - ignored_extensions
    end

    # The expanded and ordered list of extensions, including any that may later be ignored. This can be configured
    # (it is here that the :all entry is expanded to mean 'everything else'), or will default to an alphabetical list
    # of every extension found among gems and vendor/extensions directories.
    #
    #   Radiant.configuration.expanded_extension_list  # => [:name, :name, :name, :name]
    #
    # If an extension in the configurted list is not found, a LoadError will be thrown from here.
    #
    def expanded_extension_list
      # NB. it should remain possible to say config.extensions = []
      @extension_list ||= extensions ? expand_and_check(extensions) : available_extensions
    end
    
    def expand_and_check(extension_list) #:nodoc
      missing_extensions = extension_list - [:all] - available_extensions
      raise LoadError, "These configured extensions have not been found: #{missing_extensions.to_sentence}" if missing_extensions.any?
      if m = extension_list.index(:all)
        extension_list[m] = available_extensions - extension_list
      end
      extension_list.flatten
    end
    
    # Returns the checked and expanded list of extensions-to-enable. This may be derived from a list passed to
    # +config.extensions=+ or it may have defaulted to all available extensions.
    
    # Without such a call, we default to the alphabetical list of all well-formed vendor and gem extensions 
    # returned by +available_extensions+.
    # 
    #   Radiant.configuration.extensions  # => [:name, :all, :name]
    #
    def extensions
      @requested_extensions ||= available_extensions
    end
    
    # Sets the list of extensions that will be loaded and the order in which to load them.
    # It can include an :all marker to mean 'everything else' and is typically set in environment.rb:
    #   config.extensions = [:layouts, :taggable, :all]
    #   config.extensions = [:dashboard, :blog, :all]
    #   config.extensions = [:dashboard, :blog, :all, :comments]
    #
    # A LoadError is raised if any of the specified extensions can't be found.
    #
    def extensions=(extensions)
      @requested_extensions = extensions
    end
    
    # This is a configurable list of extension that should not be loaded.
    #   config.ignore_extensions = [:experimental, :broken]
    # You can also retrieve the list with +ignored_extensions+:
    #   Radiant.configuration.ignored_extensions  # => [:experimental, :broken]
    # These exclusions are applied regardless of dependencies and extension locations. A configuration that bundles
    # required extensions then ignores them will not boot and is likely to fail with errors about unitialized constants.
    #
    def ignore_extensions(array)
      self.ignored_extensions |= array
    end
    
    # Returns an alphabetical list of every extension found among all the load paths and bundled gems. Any plugin or 
    # gem whose path ends in the form +radiant-something-extension+ is considered to be an extension.
    #
    #   Radiant.configuration.available_extensions  # => [:name, :name, :name, :name]
    #
    # This method is always called during initialization, either as a default or to check that specified extensions are
    # available. One of its side effects is to populate the ExtensionLoader's list of extension root locations, later 
    # used when activating those extensions that have been enabled.
    #
    def available_extensions
      @available_extensions ||= (vendored_extensions + gem_extensions).uniq.sort.map(&:to_sym)
    end
    
    # Searches the defined extension_paths for subdirectories and returns a list of names as symbols.
    #
    #   Radiant.configuration.vendored_extensions  # => [:name, :name]
    #
    def vendored_extensions
      extension_paths.each_with_object([]) do |load_path, found|
        Dir["#{load_path}/*"].each do |path|
          if File.directory?(path)
            ep = ExtensionLoader.record_path(path)
            found << ep.name
          end
        end
      end
    end
    
    # Scans the bundled gems for any whose name match the +radiant-something-extension+ format
    # and returns a list of their names as symbols.
    #
    #   Radiant.configuration.gem_extensions  # => [:name, :name]
    #
    def gem_extensions
      Gem.loaded_specs.each_with_object([]) do |(gemname, gemspec), found|
        if gemname =~ /radiant-.*-extension$/
          ep = ExtensionLoader.record_path(gemspec.full_gem_path, gemname)
          found << ep.name
        end
      end
    end
        
    # Old extension-dependency mechanism now deprecated
    #
    def extension(ext)
      ::ActiveSupport::Deprecation.warn("Extension dependencies have been deprecated and are no longer supported in radiant 1.0. Extensions with dependencies should be packaged as gems and use the .gemspec to declare them.", caller)
    end

    # Old gem-invogation method now deprecated
    #
    def gem(name, options = {})
      ::ActiveSupport::Deprecation.warn("Please declare gem dependencies in your Gemfile (or for an extension, in the .gemspec file).", caller)
      super
    end

    # Returns the AdminUI singleton, giving get-and-set access to the tabs and partial-sets it defines.
    # More commonly accessed in the initializer via its call to +configuration.admin+.
    #
    def admin
      AdminUI.instance
    end
    
    %w{controller model view metal plugin load eager_load}.each do |type|
      define_method("add_#{type}_paths".to_sym) do |paths|
        self.send("#{type}_paths".to_sym).concat(paths)
      end
    end

  private

    # Overrides the Rails::Initializer default so that autoload paths for models, controllers etc point to 
    # directories in RADIANT_ROOT rather than in RAILS_ROOT.
    #
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
    end

    # Overrides the Rails::Initializer default to add plugin paths in RADIANT_ROOT as well as RAILS_ROOT.
    #
    def default_plugin_paths
      super + ["#{RADIANT_ROOT}/lib/plugins", "#{RADIANT_ROOT}/vendor/plugins"]
    end
    
    # Overrides the Rails::Initializer default to look for views in RADIANT_ROOT rather than RAILS_ROOT.
    #
    def default_view_path
      File.join(RADIANT_ROOT, 'app', 'views')
    end

    # Overrides the Rails::Initializer default to look for controllers in RADIANT_ROOT rather than RAILS_ROOT.
    #
    def default_controller_paths
      [File.join(RADIANT_ROOT, 'app', 'controllers')]
    end
  end

  class Initializer < Rails::Initializer
  
    # Rails::Initializer is essentially a list of startup steps and we extend it here by:
    # * overriding or extending some of those steps so that they use radiant and extension paths
    #   as well as (or instead of) the rails defaults.
    # * appending some extra steps to set up the admin UI and activate extensions
    
    def self.run(command = :process, configuration = Configuration.new) #:nodoc
      Rails.configuration = configuration
      super
    end

    # Returns true in the very unusual case where radiant has been deployed as a rails app itself, rather than 
    # loaded as a gem or from vendor/. This is only likely in situations where radiant is customised so heavily
    # that extensions are not sufficient.
    #
    def deployed_as_app?
      RADIANT_ROOT == RAILS_ROOT
    end
    
    # Extends the Rails::Initializer default to add extension paths to the autoload list.
    # Note that +default_autoload_paths+ is also overridden to point to RADIANT_ROOT.
    # 
    def set_autoload_paths
      extension_loader.paths(:load).reverse_each do |path|
        configuration.autoload_paths.unshift path
        $LOAD_PATH.unshift path
      end
      super
    end
    
    # Overrides the Rails initializer to load metal from RADIANT_ROOT and from radiant extensions.
    #
    def initialize_metal
      Rails::Rack::Metal.requested_metals = configuration.metals
      Rails::Rack::Metal.metal_paths = ["#{RADIANT_ROOT}/app/metal"] # reset Rails default to RADIANT_ROOT
      Rails::Rack::Metal.metal_paths += plugin_loader.engine_metal_paths
      Rails::Rack::Metal.metal_paths += extension_loader.paths(:metal)
    
      configuration.middleware.insert_before(
        :"ActionController::ParamsParser",
        Rails::Rack::Metal, :if => Rails::Rack::Metal.metals.any?)
    end
    
    # Extends the Rails initializer to add locale paths from RADIANT_ROOT and from radiant extensions.
    #
    def initialize_i18n
      radiant_locale_paths = Dir[File.join(RADIANT_ROOT, 'config', 'locales', '*.{rb,yml}')]
      configuration.i18n.load_path = radiant_locale_paths + extension_loader.paths(:locale)
      super
    end

    # Extends the Rails initializer to add plugin paths in extensions
    # and makes extension load paths reloadable (eg in development mode)
    #
    def add_plugin_load_paths
      configuration.add_plugin_paths(extension_loader.paths(:plugin))
      super
      ActiveSupport::Dependencies.autoload_once_paths -= extension_loader.paths(:load)
    end

    # Overrides the standard gem-loader to use Bundler instead of config.gem. This is the method normally monkey-patched
    # into Rails::Initializer from boot.rb if you follow the instructions at http://gembundler.com/rails23.html
    #
    def load_gems
      @bundler_loaded ||= Bundler.require :default, Rails.env
    end

    # Extends the Rails initializer also to load radiant extensions (which have been excluded from the list of plugins).
    #
    def load_plugins
      super
      extension_loader.load_extensions
    end
    
    # Extends the Rails initializer to run initializers from radiant and from extensions. The load order will be:
    # 1. RADIANT_ROOT/config/intializers/*.rb
    # 2. RAILS_ROOT/config/intializers/*.rb
    # 3. config/initializers/*.rb found in extensions, in extension load order.
    #
    # In the now rare case where radiant is deployed as an ordinary rails application, step 1 is skipped 
    # because it is equivalent to step 2.
    #
    def load_application_initializers
      load_radiant_initializers unless deployed_as_app?
      super
      extension_loader.load_extension_initalizers
    end

    # Loads initializers found in RADIANT_ROOT/config/initializers.
    #
    def load_radiant_initializers
      Dir["#{RADIANT_ROOT}/config/initializers/**/*.rb"].sort.each do |initializer|
        load(initializer)
      end
    end

    # Extends the Rails initializer with some extra steps at the end of initialization:
    # * hook up radiant view paths in controllers and notifiers
    # * initialize the navigation tabs in the admin interface
    # * initialize the extendable partial sets that make up the admin interface
    # * call +activate+ on all radiant extensions
    # * add extension controller paths
    # * mark extension app paths for eager loading
    #
    def after_initialize
      super
      extension_loader.activate_extensions  # also calls initialize_views
      configuration.add_controller_paths(extension_loader.paths(:controller))
      configuration.add_eager_load_paths(extension_loader.paths(:eager_load))
    end
    
    # Initializes all the admin interface elements and views. Separate here so that it can be called
    # to reset the interface before extension (re)activation.
    #
    def initialize_views
      initialize_default_admin_tabs
      initialize_framework_views
      admin.load_default_regions
    end
    
    # Initializes the core admin tabs. Separate so that it can be invoked by itself in tests.
    #
    def initialize_default_admin_tabs
      admin.initialize_nav
    end
    
    # This adds extension view paths to the standard Rails::Initializer method. 
    # In environments that don't cache templates it reloads the path set on each request, 
    # so that new extension paths are noticed without a restart.
    #
    def initialize_framework_views
      view_paths = extension_loader.paths(:view).push(configuration.view_path)
      if ActionController::Base.view_paths.blank? || !ActionView::Base.cache_template_loading?
        ActionController::Base.view_paths = ActionView::Base.process_view_paths(view_paths)
      end
      if configuration.frameworks.include?(:action_mailer) && ActionMailer::Base.view_paths.blank? || !ActionView::Base.cache_template_loading?
        ActionMailer::Base.view_paths = ActionView::Base.process_view_paths(view_paths) if configuration.frameworks.include?(:action_mailer)
      end
    end 

    # Extends the Rails initializer to make sure that extension controller paths are available when routes 
    # are initialized.
    #
    def initialize_routing
      configuration.add_controller_paths(extension_loader.paths(:controller))
      configuration.add_eager_load_paths(extension_loader.paths(:eager_load))
      super
    end

    # Returns the Radiant::AdminUI singleton so that the initializer can set up the admin interface.
    #
    def admin
      configuration.admin
    end

    # Returns the ExtensionLoader singleton that will eventually load extensions.
    #
    def extension_loader
      ExtensionLoader.instance {|l| l.initializer = self }
    end

  end
end

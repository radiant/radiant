require 'radiant/extension'
require 'radiant/extension_path'
require 'method_observer'

module Radiant
  class ExtensionLoader
    # The ExtensionLoader is reponsible for the loading, activation and reactivation of extensions. 
    # The noticing of important subdirectories is now handled by the ExtensionPath class.

    class DependenciesObserver < MethodObserver
      # Extends the reload mechanism in ActiveSupport so that extensions are deactivated and reactivated
      # when model classes are reloaded (in development mode, usually).
      
      attr_accessor :config

      def initialize(rails_config) #:nodoc
        @config = rails_config
      end

      def before_clear(*args) #:nodoc
        ExtensionLoader.deactivate_extensions
      end

      def after_clear(*args) #:nodoc
        ExtensionLoader.load_extensions
        ExtensionLoader.activate_extensions
      end
    end

    include Simpleton

    attr_accessor :initializer, :extensions

    def initialize #:nodoc
      self.extensions = []
    end

    # Returns a list of paths to all the extensions that are enabled in the configuration of this application.
    #
    def enabled_extension_paths
      ExtensionPath.enabled.map(&:to_s)
    end

    # Returns a list of all the paths discovered within extension roots of the specified type.
    # (by calling the corresponding class method on ExtensionPath).
    #
    #   extension_loader.paths(:metal)         #=> ['extension/app/metal', 'extension/app/metal']
    #   extension_loader.paths(:controller)    #=> ['extension/app/controllers', 'extension/app/controllers']
    #   extension_loader.paths(:eager_load)    #=> ['extension/app/controllers', 'extension/app/models', 'extension/app/helpers']
    #
    # For compatibility with the old loader, there are corresponding +type_paths+ methods.
    # There are also (deprecated) +add_type_paths+ methods. 
    #
    def paths(type)
      ExtensionPath.send("#{type}_paths".to_sym)
    end

    # Loads but does not activate all the extensions that have been enabled, in the configured order 
    # (which defaults to alphabetically). If an extension fails to load an error will be logged
    # but application startup will continue. If an extension doesn't exist, a LoadError will be raised
    # and startup will halt.
    #
    def load_extensions
      configuration = initializer.configuration
      @observer ||= DependenciesObserver.new(configuration).observe(::ActiveSupport::Dependencies)
      self.extensions = configuration.enabled_extensions.map { |ext| load_extension(ext) }.compact
    end
    
    # Loads the specified extension.
    #
    def load_extension(name)
      extension_path = ExtensionPath.find(name)
      begin
        constant = "#{name}_extension".camelize
        extension = constant.constantize
        extension.unloadable
        extension.path = extension_path
        extension
      rescue LoadError, NameError => e
        $stderr.puts "Could not load extension: #{name}.\n#{e.inspect}"
        nil
      end
    end
    
    # Loads all the initializers defined in enabled extensions, in the configured order.
    #
    def load_extension_initalizers
      extensions.each &:load_initializers
    end

    # Deactivates all enabled extensions.
    #
    def deactivate_extensions
      extensions.each &:deactivate
    end

    # Activates all enabled extensions and makes sure that any newly declared subclasses of Page are recognised.
    # The admin UI and views have to be reinitialized each time to pick up changes and avoid duplicates.
    #
    def activate_extensions
      initializer.initialize_views
      extensions.each &:activate
      Page.load_subclasses
    end
    alias :reactivate :activate_extensions

    class << self
      # Builds an ExtensionPath object from the supplied path, working out the name of the extension on the way.
      # The ExtensionPath object will later be used to scan and load the extension.
      # An extension name can be supplied in addition to the path. It will be processed in the usual way to 
      # remove radiant- and -extension and any verion numbering.
      #
      def record_path(path, name=nil)
        ExtensionPath.from_path(path, name)
      end
    
      # For compatibility with old calls probably still to be found in some extensions.
      #
      %w{controller model view metal plugin load locale}.each do |type|
        define_method("#{type}_paths".to_sym) do
          paths(type)
        end
        define_method("add_#{type}_paths".to_sym) do |additional_paths|
          ::ActiveSupport::Deprecation.warn("ExtensionLoader.add_#{type}_paths is has been moved and is deprecated. Please use Radiant.configuration.add_#{type}_paths", caller)
          initializer.configuration.send("add_#{type}_paths".to_sym, additional_paths)
        end
      end
    end
  end
end

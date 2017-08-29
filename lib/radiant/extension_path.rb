module Radiant
  class ExtensionPath
    # This class holds information about extensions that may be loaded. It has two roles: to remember the 
    # location of the extension so that we don't have to search for it again, and to look within that path
    # for significant application subdirectories.
    #
    # We can't just retrieve this information from the Extension class because the initializer sets up 
    # most of the application load_paths before plugins (including extensions) are loaded. You can think
    # of this as a sort of pre-extension class preparing the way for extension loading.
    #
    # You can use instances of this class to retrieve information about a particular extension:
    #
    #   ExtensionPath.new(:name, :path)
    #   ExtensionPath.find(:name)               #=> ExtensionPath instance
    #   ExtensionPath.find(:name).plugin_paths  #=> "path/vendor/plugins" if it exists and is a directory
    #   ExtensionPath.for(:name)                #=> "path"
    #
    # The initializer calls class methods to get overall lists (in configured order) of enabled load paths:
    #
    #   ExtensionPath.enabled                   #=> ["path", "path", "path", "path"]
    #   ExtensionPath.plugin_paths              #=> ["path/vendor/plugins", "path/vendor/plugins"]

    attr_accessor :name, :path
    @@known_paths = {}
    
    def initialize(options = {}) #:nodoc
      @name, @path = options[:name], options[:path]
      @@known_paths[@name.to_sym] = self
    end
    
    def required
      File.join(path, "#{name}_extension")
    end
    
    def to_s
      path
    end
    
    # Builds a new ExtensionPath object from the supplied path, working out the name of the extension by 
    # stripping the extra bits from radiant-something-extension-1.0.0 to leave just 'something'. The object
    # is returned, and also remembered here for later use by the initializer (to find load paths) and the
    # ExtensionLoader, to load and activate the extension.
    #
    # If two arguments are given, the second is taken to be the full extension name.
    #
    def self.from_path(path, name=nil)
      name = path if name.blank?
      name = File.basename(name).gsub(/^radiant-|-extension(-[\d\.a-z]+|-[a-z\d]+)*$/, '')
      new(name: name, path: path)
    end
    
    # Forgets all recorded extension paths.
    # Currently only used in testing.
    #
    def self.clear_paths!
      @@known_paths = {}
    end
    
    # Returns a list of all the likely load paths found within this extension root. It includes all of these 
    # that exist and are directories:
    #
    # * path
    # * path/lib 
    # * path/app/models 
    # * path/app/controllers
    # * path/app/metal
    # * path/app/helpers
    # * path/test/helpers
    #
    # You can call the class method ExtensionPath.load_paths to get a flattened list of all the load paths in all the enabled extensions.
    #
    def load_paths
      %w(lib app/models app/controllers app/metal app/helpers test/helpers).collect { |d| check_subdirectory(d) }.push(path).flatten.compact
    end

    # Returns a list of all the +vendor/plugin+ paths found within this extension root.
    # Call the class method ExtensionPath.plugin_paths to get a list of the plugin paths found in all enabled extensions.
    #
    def plugin_paths
      check_subdirectory("vendor/plugins")
    end

    # Returns a list of names of all the locale files found within this extension root.
    # Call the class method ExtensionPath.locale_paths to get a list of the locale files found in all enabled extensions
    # in reverse order so that locale definitions override one another correctly.
    #
    def locale_paths
      if check_subdirectory("config/locales")
        Dir[File.join("#{path}","config/locales","*.{rb,yml}")] 
      end
    end

    # Returns the app/helpers path if it is found within this extension root.
    # Call the class method ExtensionPath.helper_paths to get a list of the helper paths found in all enabled extensions.
    #
    def helper_paths
      check_subdirectory("app/helpers")
    end

    # Returns the app/models path if it is found within this extension root.
    # Call the class method ExtensionPath.model_paths to get a list of the model paths found in all enabled extensions.
    #
    def model_paths
      check_subdirectory("app/models")
    end

    # Returns the app/controllers path if it is found within this extension root.
    # Call the class method ExtensionPath.controller_paths to get a list of the controller paths found in all enabled extensions.
    #
    def controller_paths
      check_subdirectory("app/controllers")
    end

    # Returns the app/views path if it is found within this extension root. 
    # Call the class method ExtensionPath.view_paths to get a list of the view paths found in all enabled extensions
    # in reverse order so that views override one another correctly.
    #
    def view_paths
      check_subdirectory("app/views")
    end

    # Returns the app/metal path if it is found within this extension root.
    # Call the class method ExtensionPath.metal_paths to get a list of the metal paths found in all enabled extensions.
    #
    def metal_paths
      check_subdirectory("app/metal")
    end

    # Returns a list of all the rake task files found within this extension root.
    #
    def rake_task_paths
      if check_subdirectory("lib/tasks")
        Dir[File.join("#{path}","lib/tasks/**","*.rake")] 
      end
    end

    # Returns a list of extension subdirectories that should be marked for eager loading. At the moment that
    # includes all the controller, model and helper paths. The main purpose here is to ensure that extension
    # controllers are loaded before running cucumber features, and there may be a better way to achieve that.
    #
    # Call the class method ExtensionPath.eager_load_paths to get a list for all enabled extensions.
    #
    def eager_load_paths
      [controller_paths, model_paths, helper_paths].flatten.compact
    end
    
    class << self
      # Returns the ExtensionPath object for the given extension name.
      #
      def find(name)
        raise LoadError, "Cannot return path for unknown extension: #{name}" unless @@known_paths[name.to_sym]
        @@known_paths[name.to_sym]
      end
      
      # Returns the root path recorded for the given extension name.
      #
      def for(name)
        find(name).path
      end

      # Returns a list of path objects for all the enabled extensions in the configured order. 
      # If a configured extension has not been found during initialization, a LoadError will be thrown here.
      #
      # Note that at this stage, in line with the usage of config.extensions = [], the extension names
      # are being passed around as symbols.
      #
      def enabled
        enabled_extensions = Radiant.configuration.enabled_extensions
        @@known_paths.values_at(*enabled_extensions).compact
      end
      
      # Returns a list of the root paths to all the enabled extensions, in the configured order.
      #
      def enabled_paths
        enabled.map(&:path)
      end
      
      [:load_paths, :plugin_paths, :helper_paths, :model_paths, :controller_paths, :eager_load_paths].each do |m|
        define_method(m) do
          enabled.map{|ep| ep.send(m)}.flatten.compact
        end
      end
      [:locale_paths, :view_paths, :metal_paths, :rake_task_paths].each do |m|
        define_method(m) do
          enabled.map{|ep| ep.send(m)}.flatten.compact.reverse
        end
      end
    end

  private

    # If the supplied path within the extension root exists and is a directory, its absolute path is returned. Otherwise, nil.
    #
    def check_subdirectory(subpath)
      subdirectory = File.join(path, subpath)
      subdirectory if File.directory?(subdirectory)
    end
    
  end
end
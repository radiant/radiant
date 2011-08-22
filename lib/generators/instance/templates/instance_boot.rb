# Don't change this file!
# Configure your app in config/environment.rb and config/environments/*.rb

RAILS_ROOT = "#{File.dirname(__FILE__)}/.." unless defined?(RAILS_ROOT)

module Rails
  class << self
    def vendor_rails?
      File.exist?("#{RAILS_ROOT}/vendor/rails")
    end
  end
end

module Radiant
  class << self
    def boot!
      unless booted?
        preinitialize
        pick_boot.run
      end
    end

    def booted?
      defined? Radiant::Initializer
    end

    def pick_boot
      case
      when app?
        AppBoot.new
      when vendor?
        VendorBoot.new
      else
        GemBoot.new
      end
    end

    def vendor?
      File.exist?("#{RAILS_ROOT}/vendor/radiant")
    end
    
    def app?
      File.exist?("#{RAILS_ROOT}/lib/radiant.rb")
    end

    def preinitialize
      load(preinitializer_path) if File.exist?(preinitializer_path)
    end

    def loaded_via_gem?
      pick_boot.is_a? GemBoot
    end

    def preinitializer_path
      "#{RAILS_ROOT}/config/preinitializer.rb"
    end
  end

  class Boot
    def run
      load_mutex
      load_initializer
    end
    
    # RubyGems from version 1.6 does not require thread but Rails depend on it
    # This should newer rails do automaticly
    def load_mutex
      begin
        require "thread" unless defined?(Mutex)
      rescue LoadError => e
        $stderr.puts %(Mutex could not be initialized. #{load_error_message})
        exit 1
      end
    end
    
    def load_initializer
      begin
        require 'radiant'
        require 'radiant/initializer'
      rescue LoadError => e
        $stderr.puts %(Radiant could not be initialized. #{load_error_message})
        exit 1
      end
      Radiant::Initializer.run(:set_load_path)
      Radiant::Initializer.run(:install_gem_spec_stubs)
      Rails::GemDependency.add_frozen_gem_path
    end
  end

  class VendorBoot < Boot
    def load_initializer
      $LOAD_PATH.unshift "#{RAILS_ROOT}/vendor/radiant/lib" 
      super
    end
        
    def load_error_message
      "Please verify that vendor/radiant contains a complete copy of the Radiant sources."
    end
  end

  class AppBoot < Boot
    def load_initializer
      $LOAD_PATH.unshift "#{RAILS_ROOT}/lib" 
      super
    end

    def load_error_message
      "Please verify that you have a complete copy of the Radiant sources."
    end
  end

  class GemBoot < Boot
    # The location and version of the radiant gem should be set in your Gemfile
    def load_error_message
      "Have you run `bundle install`?'."
    end
  end
end

# All that for this:
Radiant.boot!

# Don't change this file!
# Configure your app in config/environment.rb and config/environments/*.rb

RAILS_ROOT = File.expand_path("#{File.dirname(__FILE__)}/..") unless defined?(RAILS_ROOT)

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

      Rails::Initializer.class_eval do
        def load_gems
          @bundler_loaded ||= Bundler.require :default, Rails.env
        end
      end

      Rails::Initializer.run(:set_load_path)
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
    def load_initializer
      self.class.load_rubygems
      load_radiant_gem
      super
    end
      
    def load_error_message
     "Please reinstall the Radiant gem with the command 'gem install radiant'."
    end

    def load_radiant_gem
      if version = self.class.gem_version
        gem 'radiant', version
      else
        gem 'radiant'
      end
    rescue Gem::LoadError => load_error
      $stderr.puts %(Missing the Radiant #{version} gem. Please `gem install -v=#{version} radiant`, update your RADIANT_GEM_VERSION setting in config/environment.rb for the Radiant version you do have installed, or comment out RADIANT_GEM_VERSION to use the latest version installed.)
      exit 1
    end

    class << self
      def rubygems_version
        Gem::RubyGemsVersion rescue nil
      end

      def gem_version
        if defined? RADIANT_GEM_VERSION
          RADIANT_GEM_VERSION
        elsif ENV.include?('RADIANT_GEM_VERSION')
          ENV['RADIANT_GEM_VERSION']
        else
          parse_gem_version(read_environment_rb)
        end
      end

      def load_rubygems
        require 'rubygems'

        min_version = '1.3.1'
        unless rubygems_version >= min_version
          $stderr.puts %(Radiant requires RubyGems >= #{min_version} (you have #{rubygems_version}). Please `gem update --system` and try again.)
          exit 1
        end

      rescue LoadError
        $stderr.puts %(Radiant requires RubyGems >= #{min_version}. Please install RubyGems and try again: http://rubygems.rubyforge.org)
        exit 1
      end

      def parse_gem_version(text)
        $1 if text =~ /^[^#]*RADIANT_GEM_VERSION\s*=\s*["']([!~<>=]*\s*[\d.]+)["']/
      end

      private
        def read_environment_rb
          File.read("#{RAILS_ROOT}/config/environment.rb")
        end
    end
  end
end

# All that for this:
Radiant.boot!

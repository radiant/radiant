RADIANT_ROOT = File.expand_path(File.join(File.dirname(__FILE__), "..")) unless defined? RADIANT_ROOT

require 'local_time'

require 'radiant/engine'

require 'radiant/initializer'
require 'radiant/extension_loader'
Radiant::ExtensionLoader.load_extensions

unless defined? Radiant::Version
  module Radiant
    module Version
      Major = '1'
      Minor = '1'
      Tiny  = '0'
      Patch = 'alpha' # set to nil for normal release

      Major = version[0]
      Minor = version[1]
      Tiny  = version[2]
      Patch = version[3]

      class << self
        def to_s
          [Major, Minor, Tiny, Patch].delete_if{|v| v.nil? }.join('.')
        end
        alias :to_str :to_s
      end
    end

    # TODO Engines should have a similar feature
    def self.loaded_via_gem?
      false
    end

    def self.app?
      true
    end
  end
end

RADIANT_ROOT = File.expand_path(File.join(File.dirname(__FILE__), "..")) unless defined? RADIANT_ROOT

require 'radiant/engine'
unless defined? Radiant::Version
  module Radiant
    module Version
      Major = '0'
      Minor = '9'
      Tiny  = '2'
      Patch = 'a' # set to nil for normal release

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
RADIANT_ROOT = File.expand_path(File.join(File.dirname(__FILE__), "..")) unless defined? RADIANT_ROOT

unless defined? Radiant::Version
  module Radiant
    module Version
      Major = '1'
      Minor = '0'
      Tiny  = '0'
      Patch = 'rc1' # set to nil for normal release

      class << self
        def to_s
          [Major, Minor, Tiny, Patch].delete_if{|v| v.nil? }.join('.')
        end
        alias :to_str :to_s
      end
    end
  end
end

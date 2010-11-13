require 'radiant'
require 'rails'

module Radiant
  class Application < Rails::Engine

  end

  module Version
    Major = '0'
    Minor = '9'
    Tiny  = '1'
    Patch = nil # set to nil for normal release

    class << self
      def to_s
        [Major, Minor, Tiny, Patch].delete_if{|v| v.nil? }.join('.')
      end
      alias :to_str :to_s
    end
  end

  def self.loaded_via_gem?
    false
  end

  def self.app?
    true
  end

end
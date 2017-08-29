RADIANT_ROOT = File.expand_path(File.join(File.dirname(__FILE__), "..")) unless defined? RADIANT_ROOT

module Radiant
  class << self
    def detail
      yield Radiant::Config if block_given?
      Radiant::Config
    end
    def configuration
      yield Rails.configuration if block_given?
      Rails.configuration
    end

    def root
      RADIANT_ROOT
    end
  end
end

require 'radiant/engine'
require 'radiant/version'

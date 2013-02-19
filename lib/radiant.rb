RADIANT_ROOT = File.expand_path(File.join(File.dirname(__FILE__), "..")) unless defined? RADIANT_ROOT

module Radiant
  def self.detail
    Radiant::Config
  end
end

require 'radiant/engine'
require 'radiant/version'

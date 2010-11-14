RADIANT_ROOT = File.expand_path(File.join(File.dirname(__FILE__), "..")) unless defined? RADIANT_ROOT

require 'radiant/engine'

require 'radiant/extension'

# Load up radiant's core extensions
Dir["#{File.dirname(__FILE__)}/../vendor/extensions/*/*_extension.rb"].each do |extension|
  warn extension
  require extension
end

# Load up any vendor extensions
Dir["#{File.dirname(__FILE__)}/../../../vendor/extensions/*/*_extension.rb"].each do |extension|
  warn extension
  require extension
end

# # Adds any plugins under this engine into the load path
# Dir["#{File.dirname(__FILE__)}/vendor/plugins/*"].each do |plugin|
#   puts plugin.inspect
#   %w( app/models app/controlers app/helpers lib ).each do |path|
#     $LOAD_PATH.unshift(File.join(plugin, path))
#   end
# end

# warn Rails.application.railties.engines.last.inspect
# extensions = Rails.application.railties.engines.select { |e| e.is_a? Radiant::Extension }
# extensions.each do |ext|
#   warn ext.inspect
  # ext.activate if ext.respond_to? :activate
#end



unless defined? Radiant::Version
  module Radiant
    module Version
      Major = '1'
      Minor = '1'
      Tiny  = '0'
      Patch = 'alpha' # set to nil for normal release

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
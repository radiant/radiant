require 'rack/cache'
# So we can subclass the storage types
require 'rack/cache/storage'
require 'rack/cache/metastore'
require 'rack/cache/entitystore'

module Radiant
  module Cache
    mattr_accessor :meta_stores, :entity_stores, :use_x_sendfile, :use_x_accel_redirect
    self.meta_stores ||= []
    self.entity_stores ||= []
    self.use_x_sendfile = false
    self.use_x_accel_redirect = nil

    def self.new(app, options={})
      self.use_x_sendfile = options.delete(:use_x_sendfile) if options[:use_x_sendfile]
      self.use_x_accel_redirect = options.delete(:use_x_accel_redirect) if options[:use_x_accel_redirect]
      Rack::Cache.new(app, {
          :private_headers => ['Authorization'],
          :entitystore => "radiant:tmp/cache/entity",
          :metastore => "radiant:tmp/cache/meta",
          :verbose => false,
          :allow_reload => false,
          :allow_revalidate => false}.merge(options))
    end

    def self.clear
      meta_stores.each {|ms| ms.clear }
      entity_stores.each {|es| es.clear }
    end

    class EntityStore < Rack::Cache::EntityStore::Disk
      def initialize(root="#{Rails.root}/tmp/cache/entity")
        super
        Radiant::Cache.entity_stores << self
      end

      def clear
        Dir[File.join(self.root, "*")].each {|file| FileUtils.rm_rf(file) }
      end
      
      def write(body)
        # Verify that the cache directory exists before attempting to write
        FileUtils.mkdir_p(self.root, :mode => 0755) unless File.directory?(self.root)
        super
      end
    end

    class MetaStore < Rack::Cache::MetaStore::Disk
      def initialize(root="#{Rails.root}/tmp/cache/meta")
        super
        Radiant::Cache.meta_stores << self
      end

      def clear
        Dir[File.join(self.root, "*")].each {|file| FileUtils.rm_rf(file) }
      end

      def store(request, response, entitystore)
        # Verify that the cache directory exists before attempting to store
        FileUtils.mkdir_p(self.root, :mode => 0755) unless File.directory?(self.root)
        super
      end

      private
      def restore_response(hash, body=nil)
        # Cribbed from the Rack::Cache source
        status = hash.delete('X-Status').to_i
        response = Rack::Cache::Response.new(status, hash, body)

        # Add acceleration headers
        if Radiant::Cache.use_x_sendfile
          accelerate(response, 'X-Sendfile', File.expand_path(body.path))
        elsif Radiant::Cache.use_x_accel_redirect
          virtual_path = File.expand_path(body.path)
          entity_path = File.expand_path(Radiant::Cache.entity_stores.first.root)
          virtual_path[entity_path] = Radiant::Cache.use_x_accel_redirect
          accelerate(response,'X-Accel-Redirect', virtual_path)
        end
        response
      end

      def accelerate(response, header, value)
        response.headers[header] = value
        response.body = []
        response.headers['Content-Length'] = '0'
      end
    end
  end
end

# Add our classes as fake constants in the right place
class Rack::Cache::EntityStore
  RADIANT = Radiant::Cache::EntityStore
end

class Rack::Cache::MetaStore
  RADIANT = Radiant::Cache::MetaStore
end
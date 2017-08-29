require 'rack/cache'
require 'fileutils'

module Radiant
  module Cache
    def self.new(backend, options = {})
      Rack::Cache.new(backend, {
        entitystore: "file:tmp/cache/entity",
        metastore: "file:tmp/cache/meta",
        verbose: false,
        allow_reload: false,
        allow_revalidate: false
      }.merge(options))
    end

    def self.clear
      [metastores.values + entitystores.values].flatten.each do |store|
        case store
        when Rack::Cache::EntityStore::Disk, Rack::Cache::MetaStore::Disk
          Dir[File.join(store.root, '*')].each do |file|
            FileUtils.rm_rf(file)
          end
        end
      end
    end

    def self.metastores
      Rack::Cache::Storage.instance.instance_variable_get('@metastores')
    end

    def self.entitystores
      Rack::Cache::Storage.instance.instance_variable_get('@entitystores')
    end
  end
end
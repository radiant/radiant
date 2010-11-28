module Radiant
  #
  # The Radiant::Config object emulates a hash with simple bracket methods
  # which allow you to get and set values in the configuration table:
  #
  #   Radiant::Config['setting.name'] = 'value'
  #   Radiant::Config['setting.name'] #=> "value"
  #
  # Currently, there is not a way to edit configuration through the admin
  # system so it must be done manually. The console script is probably the
  # easiest way to this:
  #
  #   % script/console production
  #   Loading production environment.
  #   >> Radiant::Config['setting.name'] = 'value'
  #   => "value"
  #   >>
  #
  # Radiant currently uses the following settings:
  #
  # admin.title               :: the title of the admin system
  # admin.subtitle            :: the subtitle of the admin system
  # defaults.page.parts       :: a comma separated list of default page parts
  # defaults.page.status      :: a string representation of the default page status
  # defaults.page.filter      :: the default filter to use on new page parts
  # defaults.page.fields      :: a comma separated list of the default page fields
  # dev.host                  :: the hostname where draft pages are viewable
  # local.timezone            :: the timezone name (`rake -D time` for full list)
  #                              used to correct displayed times
  # page.edit.published_date? :: when true, shows the datetime selector
  #                              for published date on the page edit screen
  class Config < ActiveRecord::Base
    set_table_name "config"
    after_save :update_cache

    class << self
      def [](key)
        if table_exists?
          unless Radiant::Config.cache_file_exists?
            Radiant::Config.ensure_cache_file
            Radiant::Config.initialize_cache
          end
          Radiant::Config.initialize_cache if Radiant::Config.stale_cache?
          Rails.cache.read('Radiant::Config')[key]
        end
      end

      def []=(key, value)
        if table_exists?
          pair = find_or_initialize_by_key(key)
          pair.update_attributes(:value => value)
          value
        end
      end

      def to_hash
        Hash[ *find(:all).map { |pair| [pair.key, pair.value] }.flatten ]
      end
      
      def initialize_cache
        Radiant::Config.ensure_cache_file
        Rails.cache.write('Radiant::Config',Radiant::Config.to_hash)
        Rails.cache.write('Radiant.cache_mtime', File.mtime(cache_file))
      end
      
      def cache_file_exists?
        File.file?(cache_file)
      end
      
      def stale_cache?
        return true unless Radiant::Config.cache_file_exists?
        Rails.cache.read('Radiant.cache_mtime') != File.mtime(cache_file)
      end
      
      def ensure_cache_file
        FileUtils.mkpath(cache_path)
        FileUtils.touch(cache_file)
      end
      
      def cache_path
        "#{Rails.root}/tmp"
      end
      
      def cache_file
        cache_file = File.join(cache_path,'radiant_config_cache.txt')
      end
    end

    def value=(param)
      self[:value] = param.to_s
    end

    def value
      if key.ends_with? "?"
        self[:value] == "true"
      else
        self[:value]
      end
    end
    
    def update_cache
      Radiant::Config.initialize_cache
    end
  end
end

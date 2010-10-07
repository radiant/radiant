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
    validate :validate_against_definition
    cattr_accessor :definitions
    
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
      
      def read_configuration_files(paths)
        initialize_definitions if definitions.nil?
        paths = [paths] unless paths.is_a? Array
        Rails.logger.warn "%%  Reading configs from #{paths.inspect}"
        paths.each { |path| load(path) if File.exist? path }
      end
      
      def prepare
        yield self if block_given?
      end
      
      def namespace(prefix, options = {}, &block)
        prefix = [options[:prefix], prefix].join('.') if options[:prefix]
        with_options(options.merge(:prefix => prefix), &block)
      end
      
      def define(key, options={})
        key = [options[:prefix], key].join('.') if options[:prefix]
        definitions[key] = Radiant::Config::Definition.new(options)
        self[key] ||= options[:default]
      end

      def initialize_definitions
        @@definitions = {}
        read_configuration_files([RAILS_ROOT + '/config/settings.rb', RADIANT_ROOT + '/config/settings.rb'].uniq)
      end
      
      def initialized?
        !!@initialized
      end
    end

    def value=(param)
      self[:value] = param.to_s
    end

    def value
      if boolean?
        checked?
      else
        self[:value]
      end
    end

    def definition
      self.class.definitions[key] ||= Radiant::Config::Definition.new
    end

    def boolean?
      definition.boolean? || key.ends_with?("?")
    end
    
    def checked?
      boolean? && self[:value] == "true"
    end
        
    def selector?
      definition.selector?
    end
    
    def selected_value
      definition.selected(value)
    end
    
    def update_cache
      Radiant::Config.initialize_cache
    end

    delegate :default, :type, :label, :allow_blank?, :hidden?, :settable?, :selection, :validation, :to => :definition

    def validate_against_definition
      if block = validation
        errors.add_to_base key + ' ' + definition.error_message unless block.call(self.value)
      end
      if selector?
        errors.add_to_base "#{value} is not one of the selectable values for #{key}" unless definition.selectable?(value)
      end
    end

  end
end

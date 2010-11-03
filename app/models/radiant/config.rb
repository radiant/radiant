module Radiant

  class << self
    def config_definitions
      @config_definitions ||= {}
    end

    def config_definitions=(definitions)
      @config_definitions = definitions
    end
  end

  class Config < ActiveRecord::Base
    #
    # The Radiant.config model class is stored in the database (and cached) but emulates a hash 
    # with simple bracket methods that allow you to get and set values like so:
    #
    #   Radiant.config['setting.name'] = 'value'
    #   Radiant.config['setting.name'] #=> "value"
    #
    # Config entries can be used freely as general-purpose global variables unless a definition
    # has been given for that key, in which case restrictions and defaults may apply. The restrictions  
    # can take the form of validations, requirements, permissions or permitted options. They are 
    # declared by calling Radiant::Config#define:
    # 
    #   # setting must be either 'foo', 'bar' or 'blank'
    #   define('admin.name', :select_from => ['foo', 'bar'])
    #
    #   # setting is (and must be) chosen from the names of currently available layouts
    #   define('shop.layout', :select_from => lambda { Layout.all.map{|l| [l.name,l.id]} }, :alow_blank => false)
    #
    #   # setting cannot be changed at runtime
    #   define('setting.important', :default => "something", :allow_change => false)
    #
    # Which almost always happens in a block like this:
    #
    #   Radiant.config do |config|
    #     config.namespace('user', :allow_change => true) do |user|
    #       user.define 'allow_password_reset?', :default => true
    #     end
    #   end
    #
    # and usually in a config/settings.rb file either in radiant itself, in the application directory
    # or in an extension. Radiant currently defines the following settings and makes them editable by 
    # admin users on the site configuration page:
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
    #
    # Helper methods are defined in ConfigurationHelper that will display config entry values
    # or edit fields:
    # 
    #   # to display label and value, where label comes from looking up the config key in the active locale
    #   show_setting('admin.name') 
    #
    #   # to display an appropriate checkbox, text field or select box with label:
    #   edit_setting('admin.name)
    #
    
    set_table_name "config"
    after_save :update_cache
    attr_reader :definition
    
    class ConfigError < RuntimeError; end
    
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
          pair.value = value
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
      
      # A convenient drying method for specifying a prefix and options common to several settings.
      # 
      #   Radiant.config do |config| 
      #     config.namespace('secret', :allow_display => false) do |secret|
      #       secret.define('identity', :default => 'batman')      # defines 'secret.identity'
      #       secret.define('lair', :default => 'batcave')         # defines 'secret.lair'
      #       secret.define('longing', :default => 'vindication')  # defines 'secret.longing'
      #     end
      #   end
      #
      def namespace(prefix, options = {}, &block)
        prefix = [options[:prefix], prefix].join('.') if options[:prefix]
        with_options(options.merge(:prefix => prefix), &block)
      end
      
      # Declares a setting definition that will constrain and support the use of a particular config entry.
      #
      #   define('setting.key', options)
      #
      # Can take several options:
      # * :default is the value that will be placed in the database if none has been set already
      # * :type can be :string, :boolean or :integer. Note that all settings whose key ends in ? are considered boolean.
      # * :select_from should be a list or hash suitable for passing to options_for_select, or a block that will return such a list at runtime
      # * :validate_with should be a block that will receive a value and return true or false. Validations are also implied by type or select_from.
      # * :allow_blank should be false if the config item must not be blank or nil
      # * :allow_change should be false if the config item can only be set, not changed. Add a default to specify an unchanging config entry.
      # * :allow_display should be false if the config item should not be showable in radius tags
      #
      # From the main radiant config/initializers/radiant_config.rb:
      #
      #   Radiant.config do |config|
      #     config.define 'defaults.locale', :select_from => lambda { Radiant::AvailableLocales.locales }, :allow_blank => true
      #     config.define 'defaults.page.parts', :default => "Body,Extended"
      #     ...
      #   end
      #
      # It's also possible to reuse a definition by passing it to define:
      #
      #   choose_layout = Radiant::Config::Definition.new(:select_from => lambda {Layout.all.map{|l| [l.name, l.d]}})
      #   define "my.layout", choose_layout
      #   define "your.layout", choose_layout
      #
      # but at the moment that's only done in testing.
      #
      def define(key, options={})
        if options.is_a? Radiant::Config::Definition
          definition = options
        else
          key = [options[:prefix], key].join('.') if options[:prefix]
          definition = Radiant::Config::Definition.new(options)
        end

        raise LoadError, "Configuration invalid: #{key} is already defined" unless definitions[key].nil? || definitions[key].empty?
        definitions[key] = definition

        if self[key].nil? && !definition.default.nil?
          begin
            self[key] = definition.default
          rescue ActiveRecord::RecordInvalid
            raise LoadError, "Default configuration invalid: value '#{definition.default}' is not allowed for '#{key}'"
          end
        end
      end
      
      def definitions
        Radiant.config_definitions
      end
      
      def definition_for(key)
        definitions[key] ||= Radiant::Config::Definition.new(:empty => true)
      end
      
      def clear_definitions!
        Radiant.config_definitions = {}
      end
      
    end
    
    # The usual way to use a config item:
    #
    #    Radiant.config['key'] = value
    #
    # is equivalent to this:
    #
    #   Radiant::Config.find_or_create_by_key('key').value = value
    #
    # Calling value= also applies any validations and restrictions that are found in the associated definition.
    # so this will raise a ConfigError if you try to change a protected config entry or a ValidationError if you 
    # set a value that is not among those permitted.
    #
    def value=(param)
      newvalue = param.to_s
      if newvalue != self[:value]
        raise ConfigError, "#{self.key} cannot be changed" unless settable? || self[:value].blank?
        if boolean?
          self[:value] = (newvalue == "0" || newvalue == "false" || newvalue.blank? ) ? "false" : "true"
        else
          self[:value] = newvalue
        end
        self.save!
      end
      self[:value]
    end

    # Requesting a config item:
    #
    #    key = Radiant.config['key']
    #
    # is equivalent to this:
    #
    #   key = Radiant::Config.find_or_create_by_key('key').value
    #
    # If the config item is boolean the response will be true or false. For items with :type => :integer it will be an integer, 
    # for everything else a string.
    # 
    def value
      if boolean?
        checked?
      else
        self[:value]
      end
    end

    # Returns the definition associated with this config item. If none has been declared this will be an empty definition
    # that does not restrict use.
    #
    def definition
      @definition ||= self.class.definition_for(self.key)
    end

    # Returns true if the item key ends with '?' or the definition specifies :type => :boolean.
    #
    def boolean?
      definition.boolean? || self.key.ends_with?("?")
    end
    
    # Returns true if the item is boolean and true.
    #
    def checked?
      return nil if self[:value].nil?
      boolean? && self[:value] == "true"
    end
    
    # Returns true if the item defintion includes a :select_from parameter that limits the range of permissible options.
    #
    def selector?
      definition.selector?
    end
    
    # Returns a name corresponding to the current setting value, if the setting definition includes a select_from parameter.
    #
    def selected_value
      definition.selected(value)
    end
    
    def update_cache
      Radiant::Config.initialize_cache
    end

    delegate :default, :type, :allow_blank?, :hidden?, :visible?, :settable?, :selection, :notes, :units, :to => :definition

    def validate
      definition.validate(self)
    end

  end
end

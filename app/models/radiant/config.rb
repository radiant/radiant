module Radiant
  #
  # The Radiant::Config object is stored in the databas (and cached) but emulates a hash 
  # with simple bracket methods which allow you to get and set values like so:
  #
  #   Radiant::Config['setting.name'] = 'value'
  #   Radiant::Config['setting.name'] #=> "value"
  #
  # Config entries can be used freely as general-purpose global variables unless a definition
  # has been given for that key, in which case restrictions and defaults may apply. The restrictions  
  # can take the form of validations, requirements, permissions or permitted options. They are 
  # declared by calling Radiant::Config#define:
  # 
  #   # setting must be either 'foo', 'bar' or 'blank'
  #   define('admin.name', :select_from => ['foo', 'bar'], :label => "Name of administrator")
  #
  #   # setting will (and must) be chosen from the names of currently available layouts
  #   define('shop.layout', :select_from => lambda { Layout.all.map{|l| [l.name,l.id]} }, :alow_blank => false)
  #
  #   # setting cannot be changed at runtime
  #   define('setting.important', :default => "something", :allow_change => false)
  #
  # Which almost always happens in a block like this:
  #
  #   Radiant::Config.prepare do |config|
  #     config.namespace('user', :allow_change => true) do |user|
  #       user.define 'allow_password_reset?', :label => 'Allow password reset?', :default => true
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
  #   # to display label and value, where label is either the defined :label or the config key:
  #   show_setting('admin.name') 
  #
  #   # to display an appropriate checkbox, text field or select box with label:
  #   edit_setting('admin.name)
  #
  class Config < ActiveRecord::Base
    set_table_name "config"
    after_save :update_cache
    cattr_accessor :definitions
    @@definitions = {}
    
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
      
      # Updates several config entries at once.
      # Called from Admin::ConfigurationController within a transaction so that if any fails, all are reverted.
      #
      def update(hash)
        hash.each_pair do |key, value|
          self[key] = value
        end
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

      # Loads a configuration file immediately.
      # config/settings.rb is read automatically from radiant root, rails root
      # and extension roots. Another file can be specified by calling
      #
      #   Radiant::Config.read_configuration_file(path)
      # 
      def read_configuration_file(path)
        initialize_definitions if definitions.nil?
        load(path) if File.exist? path
      end
      
      # Block-receiver. Similar to Routing::Routes.draw, it yields the Radiant::Config eigenclass
      # so that definitions are easily declared from anywhere:
      # 
      #   Radiant::Config.prepare do |config|
      #     config.define(...)
      #   end
      #
      def prepare
        yield self if block_given?
      end
      
      # A convenient drying method for specifying a prefix and options common to several settings.
      # 
      #   Radiant::Config.prepare do |config| 
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
      # * :label is the title used to display this setting in the admin interface. Defaults to the key if not supplied.
      # * :notes is a help message that can be displayed in the admin interface to explain the use of this config item.
      # * :type can be :string, :boolean or :integer. Note that all settings whose key ends in ? are considered boolean.
      # * :select_from should be a list or hash suitable for passing to options_for_select, or a block that will return such a list at runtime
      # * :validate_with should be a block that will receive a value and return true or false. Validations are also implied by type or select_from.
      # * :allow_blank should be false if the config item must not be blank or nil
      # * :allow_change should be false if the config item should be protected at runtime
      # * :allow_display should be false if the config item should not be showable in radius tags
      # * :error_message can specify the error message shown should validation fail
      #
      # From the main radiant config/settings.rb:
      #
      #   config.namespace('defaults', :allow_change => true, :allow_blank => true) do |defaults|
      #     defaults.define 'locale', :label => 'Default language', :select_from => lambda { Radiant::AvailableLocales.locales }
      #     defaults.namespace('page') do |page|
      #       page.define 'parts', :label => 'Default page parts', :notes => 'comma separated list of part names', :default => "Body,Extended"
      #       page.define 'status', :select_from => lambda { Status.settable_values }, :label => "Default page status", :default => "Draft"
      #       page.define 'filter', :select_from => lambda { TextFilter.descendants.map { |s| s.filter_name }.sort }, :label => "Default text filter"
      #       page.define 'fields', :label => 'Default page fields', :notes => 'comma separated list of field names'
      #     end
      #   end
      #
      # It's also possible to reuse a definition by passing it to define:
      #
      #   choose_layout = Radiant::Config::Definition.new(:select_from => lambda {Layout.all.map{|l| [l.name, l.d]}})
      #   define "my.layout", choose_layout
      #   define "your.layout", choose_layout
      #
      # but that's only used in testing at the moment.
      #
      def define(key, options={})
        if options.is_a? Radiant::Config::Definition
          definitions[key] = options
        else
          key = [options[:prefix], key].join('.') if options[:prefix]
          definitions[key] = Radiant::Config::Definition.new(options)
        end
        self[key] ||= definitions[key].default
      end
      
      # We makes sure that core settings.rb files are reloaded in dev mode by calling initialize_definitions
      # whenever read_configuration_files is called (as it will be whenever an extension reloads).
      #
      def initialize_definitions
        read_configuration_file(RAILS_ROOT + '/config/settings.rb')
        read_configuration_file(RADIANT_ROOT + '/config/settings.rb') unless RADIANT_ROOT == RAILS_ROOT
      end
    end
    
    # The usual way to use a config item:
    #
    #    Radiant::Config['key'] = value
    #
    # is equivalent to this:
    #
    #   Radiant::Config.find_or_create_by_key('key').value = value
    #
    # And calling value= also applies any validations and restrictions that are found in the associated definition.
    # so this will raise a ConfigError if you try to change a protected config entry or supply a value that is not
    # among those permitted.
    #
    def value=(param)
      newvalue = param.to_s
      if newvalue != self[:value]
        raise ConfigError, "#{self.key} cannot be changed" unless settable?
        if boolean?
          self[:value] = (newvalue == "0" || newvalue == "false" || newvalue.blank? ) ? "false" : "true"
        else
          self[:value] = newvalue
        end
        raise "ActiveRecord::RecordInvalid" unless self.valid?
        self.save
      end
      self[:value]
    end

    # Requesting a config item:
    #
    #    key = Radiant::Config['key']
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
      self.class.definitions[key] ||= Radiant::Config::Definition.new
    end

    # Returns the label for this item as defined in its definition, or the key if no label (or no definition) has been defined.
    def label
      definition.label || self.key
    end

    # Returns true if the item key ends with '?' or the definition specifies :type => :boolean.
    def boolean?
      definition.boolean? || key.ends_with?("?")
    end
    
    # Returns true if the item is boolean and true.
    def checked?
      boolean? && self[:value] == "true"
    end
    
    # Returns true if the item defintion includes a :select_from parameter that limits the range of permissible options.
    def selector?
      definition.selector?
    end
    
    # Returns a name corresponding to the current setting value, if the setting definition includes a set of name-value pairs.
    def selected_value
      definition.selected(value)
    end
    
    def update_cache
      Radiant::Config.initialize_cache
    end

    delegate :default, :type, :allow_blank?, :hidden?, :settable?, :selection, :notes, :to => :definition

    def validate
      definition.validate(self)
    end

  end
end

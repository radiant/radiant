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
  # admin.title           :: the title of the admin system
  # admin.subtitle        :: the subtitle of the admin system
  # defaults.page.parts   :: a comma separated list of default page parts
  # defaults.page.status  :: a string representation of the default page status
  # dev.host              :: the hostname where draft pages are viewable
  # local.timezone        :: the timezone offset (using a String or integer
  #                          from http://api.rubyonrails.org/classes/TimeZone.html) 
  #                          used to correct displayed times 
  class Config < ActiveRecord::Base
    set_table_name "config"

    class << self
      def [](key)
        pair = find_by_key(key)
        pair.value unless pair.nil?
      end

      def []=(key, value)
        pair = find_by_key(key)
        unless pair
          pair = new
          pair.key, pair.value = key, value
          pair.save
        else
          pair.value = value
          pair.save
        end
        value
      end

      def to_hash
        Hash[ *find(:all).map { |pair| [pair.key, pair.value] }.flatten ]
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
  end
end

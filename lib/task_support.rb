class TaskSupport
  class << self
    def establish_connection
      unless ActiveRecord::Base.connected?
        connection_hash = YAML.load_file("#{Rails.root}/config/database.yml").to_hash
        env_connection = connection_hash[RAILS_ENV]
        ActiveRecord::Base.establish_connection(env_connection)
      end
    end
    def config_export(path = "#{Rails.root}/config/radiant_config.yml")
      self.establish_connection
      FileUtils.mkdir_p(File.dirname(path))
      if File.open(File.expand_path(path), 'w') { |f| YAML.dump(Radiant::Config.to_hash.to_yaml,f) }
        puts "Radiant::Config saved to #{path}"
      end
    end
    def config_import(path = "#{Rails.root}/config/radiant_config.yml", clear = nil)
      self.establish_connection
      Radiant::Config.delete_all if clear
      if File.exist?(path)
          configs = YAML.load(YAML.load_file(path))
          configs.each do |key, value|
            c = Radiant::Config.find_or_initialize_by_key(key)
            c.value = value
            c.save
          end
        puts "Radiant::Config updated from #{path}"
      else
        puts "No file exists at #{path}"
      end
    end
  end
end
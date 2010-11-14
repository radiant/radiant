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
      if File.exist?(path)
        begin
          Radiant::Config.transaction do
            Radiant::Config.delete_all if clear
            configs = YAML.load(YAML.load_file(path))
            configs.each do |key, value|
              c = Radiant::Config.find_or_initialize_by_key(key)
              c.value = value
              c.save
            end
          end
          puts "Radiant::Config updated from #{path}"
        rescue ActiveRecord::RecordInvalid => e
          puts "IMPORT FAILED and rolled back. #{e}"
        end
      else
        puts "No file exists at #{path}"
      end
    end

    # Write the combined content of files in dir into cache_file in the same dir.
    #
    def cache_files(dir, files, cache_file)
      cache_content = files.collect { |f|
        File.read(File.join(dir, f)) }.join("\n\n")

      cache_path = File.join(dir, cache_file)
      File.delete(cache_path) if File.exists?(cache_path)
      File.open(cache_path, "w+") { |f| f.write(cache_content) }
    end

    # Reads through the layout file and returns an array of JS filenames
    #
    def find_admin_js
      layout = "#{RADIANT_ROOT}/app/views/layouts/application.html.haml"
      js_regexp = /javascript_include_tag %w\((.*)\), :cache => 'admin\/all/
      files = File.open(layout) { |f| f.read.match(js_regexp)[1].split }
      files.collect { |f| f.split('/').last + '.js' }
    end

    def cache_admin_js
      dir = "#{Rails.root}/public/javascripts/admin"
      cache_files(dir, find_admin_js, 'all.js')
    end
  end
end

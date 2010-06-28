# require_dependency 'radiant/extension_loader'

module Radiant::AvailableLocales
  
  def self.locale_paths
    root_locales = [ Rails.root + 'config/locales' ]
    # unless root_locales.empty?
    #   Radiant::ExtensionLoader.locale_paths.dup + root_locales
    # else
    #   Radiant::ExtensionLoader.locale_paths
    # end
  end
    
  def self.locales
    available_locales = {}
    Radiant.configuration.i18n.load_path.each do |path|
      if File.exists?(path) && path !~ /_available_tags/
        locale_yaml = YAML.load_file(path)
        stem = File.basename(path, '.yml')
        if locale_yaml[stem] && lang = locale_yaml[stem]["this_file_language"]
          available_locales[lang] = stem
        end
      end
    end
    available_locales.collect {|k,v| [k, v]}.sort_by { |s| s[0] }
  end

end

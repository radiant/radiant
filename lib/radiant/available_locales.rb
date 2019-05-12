module Radiant::AvailableLocales
  
  # Returns the list of available locale files in options_for_select format.
  #
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

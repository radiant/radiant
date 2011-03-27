module Radiant::AvailableLocales

  def self.locale_paths
    root_locales = [File.join(RADIANT_ROOT, 'config', 'locales'), File.join(RAILS_ROOT, 'config', 'locales')].uniq
    unless root_locales.empty?
      Radiant::ExtensionLoader.locale_paths.dup + root_locales
    else
      Radiant::ExtensionLoader.locale_paths
    end
  end

  def self.locales
    available_locales = {}

    locale_paths.each do |path|
      if File.exists? path
        Dir.glob(path + "/*.yml").collect do |x|
          result = File.basename(x, ".yml")
          # filters out the available_tags files
          result =~ /\_available_tags/ ? nil : result
        end.compact.each do |str|
          locale_file = YAML.load_file(File.join(path, str) + ".yml")
          lang = locale_file[str]["this_file_language"] if locale_file[str]
          available_locales.merge! Hash[lang, str] if lang
        end.freeze
      end
    end
    available_locales.sort_by{ |s| s[0] }
  end

end

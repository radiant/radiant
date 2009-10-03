module Radiant
  module AvailableLocales
    
    def self.locales
      locales = Dir.new("#{RADIANT_ROOT}/config/locales/").entries.collect do |x|
        x =~ /\.yml/ ? x.sub(/\.yml/,"") : nil
      end.compact.each_with_object({}) do |str, hsh|
        locale_file = YAML.load_file("#{RADIANT_ROOT}/config/locales/" + "/" + str + ".yml")
        hsh[locale_file[str]["this_file_language"]] = str if locale_file.has_key? str
      end.freeze
      locales
    end
    
  end
end
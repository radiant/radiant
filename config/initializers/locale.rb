LOCALES_DIRECTORY = "#{RAILS_ROOT}/config/locales/"
LOCALES_AVAILABLE = Dir.new(LOCALES_DIRECTORY).entries.collect do |x|
  x =~ /\.yml/ ? x.sub(/\.yml/,"") : nil
end.compact.each_with_object({}) do |str, hsh|
  name =  YAML.load_file(File.join(LOCALES_DIRECTORY, "#{str}.yml"))[str]["this_file_language"]
  hsh[name] = str
end.freeze # {"it-IT" => "Italiano", "en-US" => "American English"}
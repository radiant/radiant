namespace :radiant do
  namespace :i18n do
    
    desc "Syncs all available translations to the English master"
    task :sync => :environment do
      # All places Radiant can store locales 
      locale_paths = Radiant::AvailableLocales.locale_paths
      # The main translation root, basically where English is kept
      language_root = "#{RADIANT_ROOT}/config/locales"
      words = TranslationSupport.get_translation_keys(language_root)
      locale_paths.each do |path|
        if path == language_root || path.match('i18n_')
          Dir["#{path}/*.yml"].each do |filename|
            next if filename.match('_available_tags')
            basename = File.basename(filename, '.yml')
            puts "Syncing #{basename}"
            (comments, other) = TranslationSupport.read_file(filename, basename)
            words.each { |k,v| other[k] ||= words[k] }  # Initializing hash variable as empty if it does not exist
            other.delete_if { |k,v| !words[k] }         # Remove if not defined in en.yml
            TranslationSupport.write_file(filename, basename, comments, other)
          end
        end 
      end
    end
    
    desc "Creates or updates the English available tag descriptions"
    task :available_tags => :environment do
      descriptions = Hash.new
      Page.tag_descriptions.sort.each do |tag, desc|
        tag = '    ' + tag.gsub(':','-') + ':'
        desc = desc.gsub('    ','      ')
        descriptions[tag] = desc.gsub('%','&#37;').gsub(':','&#58;').gsub('r&#58;','r:')
      end
      # tag_descriptions = Hash.new
      # tag_descriptions['desc'] = descriptions
      comments = ''
      TranslationSupport.write_file("#{RADIANT_ROOT}/config/locales/en_available_tags.yml","en:\n desc",comments,descriptions)
    end          
    
  end
end

namespace :radiant do
  namespace :extensions do
    namespace :fr do
      
      desc "Runs the migration of the I18n Fr extension"
      task :migrate => :environment do
        require 'radiant/extension_migrator'
        if ENV["VERSION"]
          I18nFrExtension.migrator.migrate(ENV["VERSION"].to_i)
        else
          I18nFrExtension.migrator.migrate
        end
      end
      
      desc "Copies public assets of the I18n Fr to the instance public/ directory."
      task :update => :environment do
        is_svn_or_dir = proc {|path| path =~ /\.svn/ || File.directory?(path) }
        puts "Copying assets from I18nFrExtension"
        Dir[I18nFrExtension.root + "/public/**/*"].reject(&is_svn_or_dir).each do |file|
          path = file.sub(I18nFrExtension.root, '')
          directory = File.dirname(path)
          mkdir_p RAILS_ROOT + directory, :verbose => false
          cp file, RAILS_ROOT + path, :verbose => false
        end
      end  
    end
  end
end

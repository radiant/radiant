namespace :radiant do
  namespace :extensions do
    namespace :ja do
      
      desc "Runs the migration of the I18n Ja extension"
      task :migrate => :environment do
        require 'radiant/extension_migrator'
        if ENV["VERSION"]
          I18nJaExtension.migrator.migrate(ENV["VERSION"].to_i)
        else
          I18nJaExtension.migrator.migrate
        end
      end
      
      desc "Copies public assets of the I18n Ja to the instance public/ directory."
      task :update => :environment do
        is_svn_or_dir = proc {|path| path =~ /\.svn/ || File.directory?(path) }
        puts "Copying assets from I18nJaExtension"
        Dir[I18nJaExtension.root + "/public/**/*"].reject(&is_svn_or_dir).each do |file|
          path = file.sub(I18nJaExtension.root, '')
          directory = File.dirname(path)
          mkdir_p RAILS_ROOT + directory, :verbose => false
          cp file, RAILS_ROOT + path, :verbose => false
        end
      end  
    end
  end
end

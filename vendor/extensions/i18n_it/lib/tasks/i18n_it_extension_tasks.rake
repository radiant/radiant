namespace :radiant do
  namespace :extensions do
    namespace :it do
      
      desc "Runs the migration of the it language pack"
      task :migrate => :environment do
        require 'radiant/extension_migrator'
        if ENV["VERSION"]
          I18nItExtension.migrator.migrate(ENV["VERSION"].to_i)
        else
          I18nItExtension.migrator.migrate
        end
      end
      
      desc "Copies public assets of the it language pack to the instance public/ directory."
      task :update => :environment do
        is_svn_or_dir = proc {|path| path =~ /\.svn/ || File.directory?(path) }
        puts "Copying assets from I18nItExtension"
        Dir[I18nItExtension.root + "/public/**/*"].reject(&is_svn_or_dir).each do |file|
          path = file.sub(I18nItExtension.root, '')
          directory = File.dirname(path)
          mkdir_p RAILS_ROOT + directory, :verbose => false
          cp file, RAILS_ROOT + path, :verbose => false
        end
      end  
    end
  end
end

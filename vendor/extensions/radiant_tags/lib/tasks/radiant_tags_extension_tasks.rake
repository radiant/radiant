namespace :radiant do
  namespace :extensions do
    namespace :radiant_tags do
      
      desc "Runs the migration of the Radiant Tags extension"
      task :migrate => :environment do
        require 'radiant/extension_migrator'
        if ENV["VERSION"]
          RadiantTagsExtension.migrator.migrate(ENV["VERSION"].to_i)
        else
          RadiantTagsExtension.migrator.migrate
        end
      end
      
      desc "Copies public assets of the Radiant Tags to the instance public/ directory."
      task :update => :environment do
        is_svn_or_dir = proc {|path| path =~ /\.svn/ || File.directory?(path) }
        Dir[RadiantTagsExtension.root + "/public/**/*"].reject(&is_svn_or_dir).each do |file|
          path = file.sub(RadiantTagsExtension.root, '')
          directory = File.dirname(path)
          puts "Copying #{path}..."
          mkdir_p RAILS_ROOT + directory
          cp file, RAILS_ROOT + path
        end
      end  
    end
  end
end

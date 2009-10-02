namespace :radiant do
  namespace :extensions do
    namespace :foo do
      
      desc "Runs the migration of the Foo extension"
      task :migrate => :environment do
        require 'radiant/extension_migrator'
        if ENV["VERSION"]
          FooExtension.migrator.migrate(ENV["VERSION"].to_i)
        else
          FooExtension.migrator.migrate
        end
      end
      
      desc "Copies public assets of the Foo to the instance public/ directory."
      task :update => :environment do
        is_svn_or_dir = proc {|path| path =~ /\.svn/ || File.directory?(path) }
        puts "Copying assets from FooExtension"
        Dir[FooExtension.root + "/public/**/*"].reject(&is_svn_or_dir).each do |file|
          path = file.sub(FooExtension.root, '')
          directory = File.dirname(path)
          mkdir_p RAILS_ROOT + directory, :verbose => false
          cp file, RAILS_ROOT + path, :verbose => false
        end
      end  
    end
  end
end

namespace :radiant do
  namespace :extensions do
    namespace :<%= file_name %> do
      
      desc "Runs the migration of the <%= extension_name %> extension"
      task :migrate => :environment do
        require 'radiant/extension_migrator'
        if ENV["VERSION"]
          <%= class_name %>.migrator.migrate(ENV["VERSION"].to_i)
        else
          <%= class_name %>.migrator.migrate
        end
      end
      
      desc "Copies public assets of the <%= extension_name %> to the instance public/ directory."
      task :update => :environment do
        is_svn_or_dir = proc {|path| path =~ /\.svn/ || File.directory?(path) }
        puts "Copying assets from <%= class_name %>"
        Dir[<%= class_name %>.root + "/public/**/*"].reject(&is_svn_or_dir).each do |file|
          path = file.sub(<%= class_name %>.root, '')
          directory = File.dirname(path)
          mkdir_p RAILS_ROOT + directory, :verbose => false
          cp file, RAILS_ROOT + path, :verbose => false
        end
        unless <%= class_name %>.root.starts_with? RAILS_ROOT # don't need to copy vendored tasks
          puts "Copying rake tasks from <%= class_name %>"
          local_tasks_path = File.join(RAILS_ROOT, %w(lib tasks))
          mkdir_p local_tasks_path, :verbose => false
          Dir[File.join <%= class_name %>.root, %w(lib tasks *.rake)].each do |file|
            cp file, local_tasks_path, :verbose => false
          end
        end
      end  
    end
  end
end

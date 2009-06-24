namespace :radiant do
  namespace :extensions do
    namespace :paperclipped do
      
      desc "Runs the migration of the Assets extension"
      task :migrate => :environment do
        require 'radiant/extension_migrator'
        if ENV["VERSION"]
          PaperclippedExtension.migrator.migrate(ENV["VERSION"].to_i)
        else
          PaperclippedExtension.migrator.migrate
        end
      end
      
      desc "Copies public assets of the Assets to the instance public/ directory."
      task :update => :environment do
        is_svn_or_dir = proc {|path| path =~ /\.svn/ || File.directory?(path) }
        Dir[PaperclippedExtension.root + "/public/**/*"].reject(&is_svn_or_dir).each do |file|
          path = file.sub(PaperclippedExtension.root, '')
          directory = File.dirname(path)
          puts "Copying #{path}..."
          mkdir_p RAILS_ROOT + directory
          cp file, RAILS_ROOT + path
        end
        
      end
      
      desc "Exports assets from database to assets directory"
      task :export => :environment do
        asset_path = File.join(RAILS_ROOT, "assets")
        mkdir_p asset_path
        Asset.find(:all).each do |asset|
          puts "Exporting #{asset.asset_file_name}"
          cp asset.asset.path, File.join(asset_path, asset.asset_file_name)
        end
        puts "Done."
      end

      desc "Imports assets to database from assets directory"
      task :import => :environment do
        asset_path = File.join(RAILS_ROOT, "assets")
        if File.exist?(asset_path) && File.stat(asset_path).directory?
          Dir.glob("#{asset_path}/*").each do |file_with_path|
            if File.stat(file_with_path).file?
              new_asset = File.new(file_with_path) 
              puts "Creating #{File.basename(file_with_path)}"
              Asset.create :asset => new_asset
            end
          end
        end
      end
      
      desc "Migrates page attachments from the original page attachments extension into new Assets"
      task :migrate_from_page_attachments => :environment do
        puts "This task can clean up traces of the page_attachments (think table records and files currently in /public/page_attachments).
If you would like to use this mode type \"yes\", type \"no\" or just hit enter to leave them untouched for now."
        answer = STDIN.gets.chomp
        erase_tracks = answer.eql?('yes') ? true : false
        OldPageAttachment.find_all_by_parent_id(nil).each do |opa|
          asset = opa.create_paperclipped_record
          # move the actual file
          old_dir = "#{RAILS_ROOT}/public/page_attachments/0000/#{opa.id.to_s.rjust(4,'0')}"
          new_dir = "#{RAILS_ROOT}/public/assets/#{asset.id}"
          puts "Copying #{old_dir.gsub(RAILS_ROOT, '')}/#{opa.filename} to #{new_dir.gsub(RAILS_ROOT, '')}/#{opa.filename}..."
          mkdir_p new_dir
          cp old_dir + "/#{opa.filename}", new_dir + "/#{opa.filename}"
          # remove old record and remainings
          if erase_tracks
            rm_rf old_dir
          end
        end
        # regenerate thumbnails
        @assets = Asset.find(:all)
        @assets.each do |asset|
          asset.asset.reprocess!
          asset.save
        end
        puts "Done."
      end
      
    end
  end
end

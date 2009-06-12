namespace :radiant do
  namespace :import do
    namespace :prototype do
      
      desc "Import images, javascripts, and styles from prototype"
      task :assets => [:images, :javascripts, :styles]
      
      desc "Import images from prototype"
      task :images do
        FileUtils.mkpath "public/images/admin"
        FileUtils.cp_r "../prototype/images/admin", "public/images"
      end
      
      desc "Import javascripts from prototype"
      task :javascripts do
        FileUtils.mkpath "public/javascripts/admin"
        FileUtils.cp_r "../prototype/javascripts/admin", "public/javascripts"
      end
      
      desc "Import styles from prototype"
      task :styles do
        FileUtils.mkpath "public/stylesheets/sass/admin"
        FileUtils.cp_r "../prototype/stylesheets/admin", "public/stylesheets/sass"
        Dir['public/stylesheets/sass/admin/*.sass'].each do |filename|
          content = IO.read(filename)
          File.open(filename, "w") do |f|
            f.write(content.gsub(%r{@import /stylesheets/}, '@import '))
          end
        end
        FileUtils.rm_rf "public/stylesheets/admin"
      end
      
    end
  end
end
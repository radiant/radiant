namespace :radiant do
  namespace :import do
    namespace :prototype do
      
      desc "Import images, javascripts, and styles from prototype"
      task :assets => [:images, :javascripts, :stylesheets]
      
      desc "Import images from prototype"
      task :images do
        FileUtils.rm_r "public/images/admin"
        FileUtils.mkpath "public/images/admin"
        FileUtils.cp_r "../prototype/public/images/admin", "public/images"
      end
      
      desc "Import javascripts from prototype"
      task :javascripts do
        FileUtils.rm_r "public/javascripts/admin"
        FileUtils.mkpath "public/javascripts/admin"
        FileUtils.cp_r "../prototype/public/javascripts/admin", "public/javascripts"
      end
      
      desc "Import stylesheets from prototype"
      task :stylesheets do
        FileUtils.rm_r "public/stylesheets/sass/admin"
        FileUtils.mkpath "public/stylesheets/sass/admin"
        FileUtils.cp_r "../prototype/stylesheets/admin", "public/stylesheets/sass"
      end
      
    end
  end
end
class AddDefaultContentTypes < ActiveRecord::Migration
  
  class Config < ActiveRecord::Base; end
  
  def self.up
    Radiant::Config['assets.content_types'] =  "image/jpeg, image/pjpeg, image/gif, image/png, image/x-png, image/jpg, video/x-m4v, video/quicktime, application/x-shockwave-flash, audio/mpeg, video/mpeg"
    Radiant::Config['assets.max_asset_size'] = 5
    puts "-- Setting default content types in Radiant::Config"
    if defined? SettingsExtension && Radiant::Config.column_names.include?('description')
      Config.find(:all).each do |c|
       description = case c.key
         when 'assets.content_types'
           'Defines the content types of that will be allowed to be uploaded as assets.'
       
         when 'assets.max_asset_size'
           'The size in megabytes that will be the max size allowed to be uploaded for an asset'
         else
           c.description
       end
       c.update_attribute :description, description
      end
    end
  end

  def self.down

  end
  
end
class AddDefaultConfigs < ActiveRecord::Migration
  
  class Config < ActiveRecord::Base; end
  
  def self.up
    Radiant::Config['assets.additional_thumbnails'] = "normal=640x640>"
    Radiant::Config['assets.display_size'] = "original"
    puts "-- Setting default display sizes in Radiant::Config"
    if defined? SettingsExtension && Radiant::Config.column_names.include?('description')
      Config.find(:all).each do |c|
       description = case c.key
         when 'assets.additional_thumbnails'
           'Defines the default sizes for image assets that are created when an image is uploaded. Use "#" to crop the image to a specific size. "42x42#" would be a square thumbnail, cropped in the center 42 pixels by 42 pixels.'
       
         when 'assets.display_size'
           'Sets which of your image sizes is shown is the edit view. Defaults to the "original" image size, but any size may be used. '
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
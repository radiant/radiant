Radiant.config do |config|
  # this file can be used to set defaults, options and validation rules for local configuration settings.
  # core settings are defined in RADIANT_ROOT/config/initializers/radiant_config.rb and by the corresponding 
  # file in each radiant extension. You probably don't need to add anything here, but in case you do:

  # config.define 'site.show_footer?', :default => "true"
  # config.define 'S3.bucket', :default => "key", :allow_change => false

  # you can also use this file to set config values (by environment, for example):
  
  # if RAILS_ENV == 'production'
  #   config['cache.duration'] = 86400
  # else
  #   config['cache.duration'] = 0
  # end
end 

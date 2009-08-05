require 'task_support'
namespace :radiant do
  namespace :config do
    desc "Export Radiant::Config to Rails.root/config/radiant_config.yml. Specify a path with RADIANT_CONFIG_PATH - defaults to Rails.root/config/radiant_config.yml"
    task :export => :environment do
      config_path = ENV['RADIANT_CONFIG_PATH'] || "#{Rails.root}/config/radiant_config.yml"
      clear = ENV['CLEAR_CONFIG'] || nil
      TaskSupport.config_export(config_path)
    end
    
    desc "Import Radiant::Config from Rails.root/config/radiant_config.yml. Specify a path with RADIANT_CONFIG_PATH - defaults to Rails.root/config/radiant_config.yml Set CLEAR_CONFIG=true to delete all existing settings before import"
    task :import => :environment do
      config_path = ENV['RADIANT_CONFIG_PATH'] || "#{Rails.root}/config/radiant_config.yml"
      clear = ENV['CLEAR_CONFIG'] || nil
      TaskSupport.config_import(config_path, clear)
    end
  end
end
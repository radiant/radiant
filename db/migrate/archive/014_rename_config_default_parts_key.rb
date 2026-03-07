class RenameConfigDefaultPartsKey < ActiveRecord::Migration
  
  def self.up
    rename_config_key 'default.parts', 'defaults.page.parts'
  end

  def self.down
    rename_config_key 'defaults.page.parts', 'default.parts'
  end
  
  def self.rename_config_key(from, to)
    return unless setting = Radiant::Config.find_by_key(from)
    setting.key = to
    setting.save!
  end
  
end

class MergeBehaviorsAndPages < ActiveRecord::Migration
  class OldPage < ActiveRecord::Base
    set_table_name 'pages'
  end
  
  @@page_map = {
    "Page Missing" => "FileNotFoundPage"
  }
  
  @@behavior_map = @@page_map.invert
  
  def self.up
    announce "converting behavior names to class names"
    OldPage.find(:all).each do |page|
      unless page.behavior_id.blank?
        page.behavior_id = page_name(page.behavior_id)
        page.save!
      end
    end
    rename_column :pages, :behavior_id, :type
  end

  def self.down
    rename_column :pages, :type, :behavior_id
    OldPage.reset_column_information
    announce "converting class names back to behavior names"
    OldPage.find(:all).each do |page|
      unless page.behavior_id.blank?
        page.behavior_id = behavior_name(page.behavior_id)
        page.save!
      end
    end
  end
  
  def self.page_name(behavior_name)
    if @@page_map.has_key?(behavior_name)
      @@page_map[behavior_name]
    else
      name = behavior_name.scan(/\w+/).map { |word| word.capitalize }.join
      name = $1 if name =~ /^(.*?)Behavior$/
      name += "Page" unless name =~ /Page$/
      name
    end
  end
  
  def self.behavior_name(page_name)
    if @@behavior_map.has_key?(page_name)
      @@behavior_map[page_name]
    else
      name = page_name.gsub(/(^.|[A-Z])/, ' \1').strip
      name = $1 if name =~ /^(.*)Page$/
      name
    end
  end
  

end

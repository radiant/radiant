class AddUserLanguage < ActiveRecord::Migration
  def self.up  
    add_column :users, :language, :string
  end

  def self.down    
    remove_column :users, :language
  end
end

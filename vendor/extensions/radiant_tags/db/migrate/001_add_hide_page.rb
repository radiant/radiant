class AddHidePage < ActiveRecord::Migration
  def self.up
    add_column :pages, :hide_in_menu, :boolean
  end
  
  def self.down
    remove_column :pages, :hide_in_menu
  end
end
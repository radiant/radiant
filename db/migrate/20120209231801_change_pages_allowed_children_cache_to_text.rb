class ChangePagesAllowedChildrenCacheToText  < ActiveRecord::Migration
  def self.up
    unless Page.columns_hash['allowed_children_cache'].type == :text
      change_column :pages, :allowed_children_cache, :text
    end
  end

  def self.down
    change_column :pages, :allowed_children_cache, :string, :limit => 1500
  end
end
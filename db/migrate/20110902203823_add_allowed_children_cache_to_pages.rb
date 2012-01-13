class AddAllowedChildrenCacheToPages < ActiveRecord::Migration
  def self.up
    add_column :pages, :allowed_children_cache, :string, :limit => 1500, :default => ''
    Page.reset_column_information
    Page.find_each do |page|
      page.save # update the allowed_children_cache
    end
  end

  def self.down
    remove_column :pages, :allowed_children_cache
  end
end
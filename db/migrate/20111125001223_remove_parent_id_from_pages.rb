class RemoveParentIdFromPages < ActiveRecord::Migration
  def self.up
    remove_index :pages, :parent_id
    remove_column :pages, :parent_id, :integer
  end

  def self.down
    add_column :pages, :parent_id
    add_index :pages, :parent_id
  end
end
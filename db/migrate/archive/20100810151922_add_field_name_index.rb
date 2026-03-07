class AddFieldNameIndex < ActiveRecord::Migration
  def self.up
    remove_index :page_fields, :page_id
    add_index :page_fields, [:page_id, :name, :content]
  end

  def self.down
    remove_index :page_fields, [:page_id, :name, :content]
    add_index :page_fields, :page_id
  end
end

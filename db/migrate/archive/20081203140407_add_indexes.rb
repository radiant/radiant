class AddIndexes < ActiveRecord::Migration
  def self.up
    add_index :pages,       :class_name,            :name => 'pages_class_name'
    add_index :pages,       :parent_id,             :name => 'pages_parent_id'
    add_index :pages,       %w{slug parent_id},     :name => 'pages_child_slug'
    add_index :pages,       %w{virtual status_id},  :name => 'pages_published'
    
    add_index :page_parts,  %w{page_id name},       :name => 'parts_by_page'
  end

  def self.down
    remove_index :page_parts, :name => 'parts_by_page'
                              
    remove_index :pages,      :name => 'pages_published'
    remove_index :pages,      :name => 'pages_child_slug'
    remove_index :pages,      :name => 'pages_parent_id'
    remove_index :pages,      :name => 'pages_class_name'
  end
end

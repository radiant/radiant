class RenameTypeColumnOnPageToClassName < ActiveRecord::Migration
  def self.up
    rename_column 'pages', 'type', 'class_name'
  end

  def self.down
    rename_column 'pages', 'class_name', 'type'
  end
end

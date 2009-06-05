class CreatePageAttachments < ActiveRecord::Migration
  def self.up
    
    # See if a page_attachments table from the original 'page_attachments' extension already exists
    # If so, rename the table to old_page_attachments so they can be migrated later
    if ActiveRecord::Base.connection.tables.include?('page_attachments')
      rename_table :page_attachments, :old_page_attachments
    end
    create_table :page_attachments do |t|
      t.column :asset_id,     :integer
      t.column :page_id,      :integer
      t.column :position,    :integer
    end
    
  end
  
  def self.down
    drop_table :page_attachments
  end
end
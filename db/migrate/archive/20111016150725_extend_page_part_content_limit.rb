class ExtendPagePartContentLimit < ActiveRecord::Migration
  def self.up
    if ActiveRecord::Base.connection.adapter_name =~ /m[sy]sql/i
      # Make sure text longer than 64kB is not cropped in MySQL and MSSQL
      # See https://github.com/radiant/radiant-sheets-extension/issues/10
      change_column :page_parts, :content, :text, :limit => 1048575
    end
  end

  def self.down
    if ActiveRecord::Base.connection.adapter_name =~ /m[sy]sql/i
      change_column :page_parts, :content, :text
    end
  end
end
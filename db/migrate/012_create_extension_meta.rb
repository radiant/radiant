class CreateExtensionMeta < ActiveRecord::Migration
  def self.up
    create_table 'extension_meta', :force => true do |t|
      t.column 'name', :string
      t.column 'schema_version', :integer, :default => 0
      t.column 'enabled', :boolean, :default => true
    end
  end

  def self.down
    drop_table 'extension_meta'
  end
end

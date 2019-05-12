class AddContentTypeFieldToLayout < ActiveRecord::Migration
  def self.up
    add_column "layouts", "content_type", :string, :limit => 40
  end

  def self.down
    remove_column "layouts", "content_type"
  end
end

class AddVirtualColumnToPageAgain < ActiveRecord::Migration
  def self.up
    add_column "pages", "virtual", :boolean, :null => false, :default => false
  end

  def self.down
    remove_column "pages", "virtual"
  end
end
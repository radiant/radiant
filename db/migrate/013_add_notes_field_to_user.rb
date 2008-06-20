class AddNotesFieldToUser < ActiveRecord::Migration
  def self.up
    add_column "users", "notes", :text
  end

  def self.down
    remove_column "users", "notes"
  end
end

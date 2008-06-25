class AddSessionInfoToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :session_token, :string
    add_column :users, :session_expire, :datetime
  end

  def self.down
    remove_column :users, :session_token
    remove_column :users, :session_expire
  end
end
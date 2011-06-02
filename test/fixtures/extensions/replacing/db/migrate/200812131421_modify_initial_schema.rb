class ModifyInitialSchema < ActiveRecord::Migration
  def self.up
    create_table "places", :force => true do |t|
    end
  end
  
  def self.down
    drop_table "places"
  end
end
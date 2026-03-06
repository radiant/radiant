class CreateInitialSchema < ActiveRecord::Migration
  def self.up
    create_table "people", :force => true do |t|
    end
  end
  
  def self.down
    drop_table "people"
  end
end
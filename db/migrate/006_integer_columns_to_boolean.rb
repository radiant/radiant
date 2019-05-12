class IntegerColumnsToBoolean < ActiveRecord::Migration
  
  class User < ActiveRecord::Base; end
  
  def self.up
    change_column "users", "admin",     :boolean, :default => false, :null => false
    change_column "users", "developer", :boolean, :default => false, :null => false
  end
  
  def self.down
    change_column "users", "admin",     :integer, :limit => 1, :default => 0, :null => false
    change_column "users", "developer", :integer, :limit => 1, :default => 0, :null => false
  end
  
  def self.change_column(table, column, type, options={})
    model_class = table.singularize.camelize.constantize
    
    announce "saving #{model_class} data"
    old_values = model_class.find(:all).map do |model|
      [model.id, model.send("#{column}?")]
    end
    
    remove_column table, column
    add_column table, column, type, options
    
    model_class.reset_column_information
    
    announce "restoring #{model_class} data"
    old_values.each do |(id, value)|
      model = model_class.find(id)
      model.send "#{column}=", value
      model.save
    end
  end
  
end

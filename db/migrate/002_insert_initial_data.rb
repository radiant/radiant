class InsertInitialData < ActiveRecord::Migration
  
  # Historical. We no longer rely on this migration to insert the initial data into
  # the database. Instead we recommend `rake db:bootstrap`.

  def self.up
  end

  def self.down
  end
  
end

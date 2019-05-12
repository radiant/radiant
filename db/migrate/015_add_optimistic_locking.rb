class AddOptimisticLocking < ActiveRecord::Migration
  
  def self.up
    [:pages, :layouts, :snippets, :users].each do |table|
      add_column table, :lock_version, :integer, :default => 0
    end
  end

  def self.down
    [:pages, :layouts, :snippets, :users].each do |table|
      remove_column table, :lock_version
    end
  end
  
end

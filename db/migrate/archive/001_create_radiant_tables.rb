class CreateRadiantTables < ActiveRecord::Migration
  def self.up
    create_table "config", :force => true do |t|
      t.column "key", :string, :limit => 40, :default => "", :null => false
      t.column "value", :string, :default => ""
    end
    add_index "config", ["key"], :name => "key", :unique => true 

    create_table "pages", :force => true do |t|
      t.column "title", :string
      t.column "slug", :string, :limit => 100
      t.column "breadcrumb", :string, :limit => 160
      t.column "behavior", :string, :limit => 25
      t.column "status_id", :integer, :default => 1, :null => false
      t.column "parent_id", :integer
      t.column "layout_id", :integer
      t.column "created_at", :datetime
      t.column "updated_at", :datetime
      t.column "published_at", :datetime
      t.column "created_by", :integer
      t.column "updated_by", :integer
    end

    create_table "page_parts", :force => true do |t|
      t.column "name", :string, :limit => 100
      t.column "filter", :string, :limit => 25
      t.column "content", :text
      t.column "page_id", :integer
    end

    create_table "snippets", :force => true do |t|
      t.column "name", :string, :limit => 100, :default => "", :null => false
      t.column "filter", :string, :limit => 25
      t.column "content", :text
      t.column "created_at", :datetime
      t.column "updated_at", :datetime
      t.column "created_by", :integer
      t.column "updated_by", :integer
    end
    add_index "snippets", ["name"], :name => "name", :unique => true

    create_table "layouts", :force => true do |t|
      t.column "name", :string, :limit => 100
      t.column "content", :text
      t.column "created_at", :datetime
      t.column "updated_at", :datetime
      t.column "created_by", :integer
      t.column "updated_by", :integer
    end
    
    create_table "users", :force => true do |t|
      t.column "name", :string, :limit => 100
      t.column "email", :string
      t.column "login", :string, :limit => 40, :default => "", :null => false
      t.column "password", :string, :limit => 40
      t.column "admin", :integer, :limit => 1, :default => 0, :null => false
      t.column "developer", :integer, :limit => 1, :default => 0, :null => false
      t.column "created_at", :datetime
      t.column "updated_at", :datetime
      t.column "created_by", :integer
      t.column "updated_by", :integer
    end
    add_index "users", ["login"], :name => "login", :unique => true
  
  end

  def self.down
    drop_table "pages"
    drop_table "page_parts"
    drop_table "snippets"
    drop_table "layouts"
    drop_table "users"
    drop_table "config"
  end
end

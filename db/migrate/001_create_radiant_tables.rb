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
      t.column "class_name", :string, :limit => 25
      t.column "status_id", :integer, :default => 1, :null => false
      t.column "parent_id", :integer
      t.column "layout_id", :integer
      t.column "created_at", :datetime
      t.column "updated_at", :datetime
      t.column "published_at", :datetime
      t.column "created_by_id", :integer
      t.column "updated_by", :integer
      t.column "virtual", :boolean, :null => false, :default => false
      t.column "lock_version", :integer, :default => 0
      t.column "allowed_children_cache", :text, :default => ''
    end
    add_index :pages,       :class_name,            :name => 'pages_class_name'
    add_index :pages,       :parent_id,             :name => 'pages_parent_id'
    add_index :pages,       %w{slug parent_id},     :name => 'pages_child_slug'
    add_index :pages,       %w{virtual status_id},  :name => 'pages_published'

    create_table "page_parts", :force => true do |t|
      t.column "name", :string, :limit => 100
      t.column "filter_id", :string, :limit => 25
      # Make sure text longer than 64kB is not cropped in MySQL and MSSQL
      # See https://github.com/radiant/radiant-sheets-extension/issues/10
      if ActiveRecord::Base.connection.adapter_name =~ /m[sy]sql/i
        t.column "content", :text, :limit => 1048575
      else
        t.column "content", :text
      end
      t.column "page_id", :integer
    end
    add_index :page_parts,  %w{page_id name},       :name => 'parts_by_page'

    create_table "page_fields" do |t|
      t.column "page_id", :integer
      t.column "name", :string
      t.column "content", :string
    end
    add_index "page_fields", [:page_id, :name, :content]

    create_table "snippets", :force => true do |t|
      t.column "name", :string, :limit => 100, :default => "", :null => false
      t.column "filter_id", :string, :limit => 25
      t.column "content", :text
      t.column "created_at", :datetime
      t.column "updated_at", :datetime
      t.column "created_by_id", :integer
      t.column "updated_by", :integer
      t.column "lock_version", :integer, :default => 0
    end
    add_index "snippets", ["name"], :name => "name", :unique => true

    create_table "layouts", :force => true do |t|
      t.column "name", :string, :limit => 100
      t.column "content", :text
      t.column "created_at", :datetime
      t.column "updated_at", :datetime
      t.column "created_by_id", :integer
      t.column "updated_by", :integer
      t.column "content_type", :string, :limit => 40
      t.column "lock_version", :integer, :default => 0
    end
    
    create_table "users", :force => true do |t|
      t.column "name", :string, :limit => 100
      t.column "email", :string
      t.column "login", :string, :limit => 40, :default => "", :null => false
      t.column "password", :string, :limit => 40
      t.column "admin", :boolean, :default => false, :null => false
      t.column "designer", :boolean, :default => false, :null => false
      t.column "created_at", :datetime
      t.column "updated_at", :datetime
      t.column "created_by_id", :integer
      t.column "updated_by", :integer
      t.column "notes", :text
      t.column "lock_version", :integer, :default => 0
      t.column "salt", :string, :default => "sweet harmonious biscuits"
      t.column "session_token", :string
      t.column "locale", :string
    end
    add_index "users", ["login"], :name => "login", :unique => true
  
    create_table 'extension_meta', :force => true do |t|
      t.column 'name', :string
      t.column 'schema_version', :integer, :default => 0
      t.column 'enabled', :boolean, :default => true
    end

    create_table :sessions do |t|
      t.column :session_id, :string
      t.column :data, :text
      t.column :updated_at, :datetime
    end

    add_index :sessions, :session_id
    add_index :sessions, :updated_at
  end

  def self.down
    drop_table "pages"
    drop_table "page_parts"
    drop_table "snippets"
    drop_table "layouts"
    drop_table "users"
    drop_table "config"
    drop_table "extension_meta"
    drop_table "sessions"
  end
end

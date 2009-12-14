ActiveRecord::Schema.define(:version => 20081126181722) do
  create_table :people, :force => true do |t|
    t.column :first_name, :string
    t.column :last_name, :string
  end
  
  create_table :places_table, :force => true do |t|
    t.column :name, :string
    t.column :location, :string 
    t.column :type, :string
  end
  
  create_table :things, :force => true do |t|
    t.column :name, :string
    t.column :description, :string
    t.column :created_on, :date
    t.column :updated_on, :date
  end
  
  create_table :notes, :force => true do |t|
    t.column :person_id, :integer
    t.column :content, :string
    t.column :created_at, :datetime
    t.column :updated_at, :datetime
  end
end

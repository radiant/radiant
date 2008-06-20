ActiveRecord::Schema.define do
  create_table :people, :force => true do |t|
    t.column :first_name, :string
    t.column :last_name, :string
  end
  
  create_table :places, :force => true do |t|
    t.column :name, :string
    t.column :location, :string 
  end
  
  create_table :things, :force => true do |t|
    t.column :name, :string
    t.column :description, :string
  end
  
  create_table :side_effecty_things, :force => true do |t|
  end

  create_table :models, :force => true do |t|
    t.column :name, :string
    t.column :description, :string
  end
  
  create_table :notes, :force => true do |t|
    t.column :content, :string
    t.column :created_at, :datetime
    t.column :updated_at, :datetime
  end
end
  
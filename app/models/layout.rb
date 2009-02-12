class Layout < ActiveRecord::Base
  
  # Default Order
  order_by 'name'

  # Associations
  has_many :pages
  belongs_to :created_by, :class_name => 'User'
  belongs_to :updated_by, :class_name => 'User'

  # Validations
  validates_presence_of :name, :message => 'required'
  validates_uniqueness_of :name, :message => 'name already in use'
  validates_length_of :name, :maximum => 100, :message => '{{count}}-character limit'

end
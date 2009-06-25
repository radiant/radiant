class Layout < ActiveRecord::Base
  
  # Default Order
  default_scope :order => "name"

  # Associations
  has_many :pages
  belongs_to :created_by, :class_name => 'User'
  belongs_to :updated_by, :class_name => 'User'

  # Validations
  validates_presence_of :name
  validates_uniqueness_of :name
  validates_length_of :name, :maximum => 100
end
class Snippet < ActiveRecord::Base
  
  # Default Order
  default_scope :order => 'name'
  
  # Associations
  belongs_to :created_by, :class_name => 'User'
  belongs_to :updated_by, :class_name => 'User'

  # Validations
  validates_presence_of :name, :message => 'required'
  validates_length_of :name, :maximum => 100, :message => '{{count}}-character limit'
  validates_length_of :filter_id, :maximum => 25, :allow_nil => true, :message => '{{count}}-character limit'
  validates_format_of :name, :with => %r{^\S*$}, :message => 'cannot contain spaces or tabs'
  validates_uniqueness_of :name, :message => 'name already in use'
  
  object_id_attr :filter, TextFilter

end

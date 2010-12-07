class Snippet < ActiveRecord::Base
  
  # Default Order
  default_scope :order => 'name'
  
  # Associations
  belongs_to :created_by, :class_name => 'User'
  belongs_to :updated_by, :class_name => 'User'

  # Validations
  validates_presence_of :name
  validates_length_of :name, :maximum => 100
  validates_length_of :filter_id, :maximum => 25, :allow_nil => true
  validates_format_of :name, :with => %r{^\S*$}
  validates_uniqueness_of :name
  
  object_id_attr :filter, TextFilter

  def after_initialize
    self.filter_id ||= Radiant::Config['defaults.snippet.filter'] if new_record?
  end

end

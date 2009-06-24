class Snippet < ActiveRecord::Base
  
  # Default Order
  default_scope :order => 'name'
  
  # Associations
  belongs_to :created_by, :class_name => 'User'
  belongs_to :updated_by, :class_name => 'User'

  # Validations
  validates_presence_of :name, :message => I18n.t('models.required')
  validates_length_of :name, :maximum => 100, :message => I18n.t('models.character_limit', :count => count)
  validates_length_of :filter_id, :maximum => 25, :allow_nil => true, :message => I18n.t('models.character_limit', :count => count)
  validates_format_of :name, :with => %r{^\S*$}, :message => I18n.t('model.no_spaces_tabs')
  validates_uniqueness_of :name, :message => I18n.t('models.name_in_use')
  
  object_id_attr :filter, TextFilter

end

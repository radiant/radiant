class Layout < ActiveRecord::Base
  
  # Default Order
  default_scope :order => "name"

  # Associations
  has_many :pages
  belongs_to :created_by, :class_name => 'User'
  belongs_to :updated_by, :class_name => 'User'

  # Validations
  validates_presence_of :name, :message => I18n.t('models.required')
  validates_uniqueness_of :name, :message => I18n.t('models.name_in_use')
  validates_length_of :name, :maximum => 100, :message => I18n.t('models.character_limit', :count => count)

end
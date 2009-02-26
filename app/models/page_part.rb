class PagePart < ActiveRecord::Base
  
  # Default Order
  order_by 'name'
  
  # Associations
  belongs_to :page
  
  # Validations
  validates_presence_of :name, :message => I18n.t('models.required')
  validates_length_of :name, :maximum => 100, :message => I18n.t('models.character_limit', :count => count)
  validates_length_of :filter_id, :maximum => 25, :allow_nil => true, :message => I18n.t('models.character_limit', :count => count)
  validates_numericality_of :id, :page_id, :allow_nil => true, :only_integer => true, :message => I18n.t('models.must_be_number')
  
  object_id_attr :filter, TextFilter

  def after_initialize
    self.filter_id ||= Radiant::Config['defaults.page.filter'] if new_record?
  end

end

class PagePart < ActiveRecord::Base

  # Default Order
  default_scope :order => 'name'

  # Associations
  belongs_to :page

  # Validations
  validates_presence_of :name
  validates_length_of :name, :maximum => 100
  validates_length_of :filter_id, :maximum => 25, :allow_nil => true

  def after_initialize
    self.filter_id ||= Radiant::Config['defaults.page.filter'] if new_record?
  end

  def filter
    if @filter.nil? or (@old_filter_id != filter_id)
      @old_filter_id = filter_id
      klass = TextFilter.descendants.find { |d| d.filter_name == filter_id }
      klass ||= TextFilter
      @filter = klass.new
    else
      @filter
    end
  end

end

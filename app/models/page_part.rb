class PagePart < ActiveRecord::Base
  self.table_name = 'page_parts'
  after_initialize :set_filter_id_from_config
  attr_accessible :name, :filter_id, :content

  # Default Order
  default_scope { order('name') }

  # Associations
  belongs_to :page

  # Validations
  validates_presence_of :name
  validates_length_of :name, maximum: 100
  validates_length_of :filter_id, maximum: 25, allow_nil: true

  def set_filter_id_from_config
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

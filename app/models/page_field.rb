class PageField < ActiveRecord::Base
  self.table_name = 'page_fields'
  validates_presence_of :name
  attr_accessible :name, :content
end

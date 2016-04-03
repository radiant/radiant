class PageField < ActiveRecord::Base
  self.table_name = 'page_fields'
  validates_presence_of :name
end

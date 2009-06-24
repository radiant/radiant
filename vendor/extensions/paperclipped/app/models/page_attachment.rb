class PageAttachment < ActiveRecord::Base
  
  belongs_to :asset
  belongs_to :page
  
  acts_as_list :scope => :page_id
  
end
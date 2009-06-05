module PageAssetAssociations
  
  def self.included(base)
    base.class_eval {
      has_many :page_attachments, :order => :position
      has_many :assets, :through => :page_attachments
    }
  end
  
end
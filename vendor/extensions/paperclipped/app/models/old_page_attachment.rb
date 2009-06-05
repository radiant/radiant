class OldPageAttachment < ActiveRecord::Base
    def create_paperclipped_record
      options = {
        :asset_file_size => size,
        :asset_file_name => filename,
        :asset_content_type => content_type,
        :created_by_id => created_by
      }
      
      # In newer versions of page_attachments we have title and description fields.
      options[:title] = title if respond_to?(:title)
      options[:caption] = description if respond_to?(:description)
      
      a = Asset.new(options)
      a.save
      
      # Re-attach the asset to it's page
      page = Page.find(page_id)
      p = PageAttachment.create(:asset_id => a.id, :page_id => page.id)
      
      # Circumvent acts_as_list before_create filter to set the original page_attachment position.
      PageAttachment.update_all("position=#{position}", "id=#{p.id}") if respond_to?(:position)
      
      a
    end          
end
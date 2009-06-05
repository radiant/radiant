class RadiantTagsExtension < Radiant::Extension
  version "1.0"
  description "Describe your extension here"
  url "http://yourwebsite.com/radiant_tags"
  
  # define_routes do |map|
  #   map.connect 'admin/radiant_tags/:action', :controller => 'admin/radiant_tags'
  # end
  
  def activate
    Page.send :include, ExtraRadiantTags
    Admin::PagesController.send :include, InterfaceAdditions
    
    # admin.page.edit.add :form, "/admin/page/hide_page", :before => "edit_extended_metadata"
    # admin.tabs.remove "Assets"
    # admin.tabs.add "Bilder", "/admin/assets", :after => "Snippets", :visibility => [:all]
    # admin.tabs.remove "Pages"
    # admin.tabs.add "Seiten", "/admin/pages", :before => "Snippets", :visibility => [:all]
  end
  
  def deactivate
    # admin.tabs.remove "Radiant Tags"
  end
  
end
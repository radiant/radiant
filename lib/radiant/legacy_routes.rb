module Radiant::LegacyRoutes
  { 
    :page_index => :admin_pages,
    :page_edit => :edit_admin_page,
    :page_new => :new_admin_page_child,
    :homepage_new => :new_admin_page,
    :page_remove => :remove_admin_page,
    :page_children => :admin_page_children,
    :page_add_part => :admin_page_page_parts,
    :layout_index => :admin_layouts,
    :layout_edit => :edit_admin_layout,
    :layout_new => :new_admin_layout,
    :layout_remove => :remove_admin_layout,
    :snippet_index => :admin_snippets,
    :snippet_edit => :edit_admin_snippet,
    :snippet_new => :new_admin_snippet,
    :snippet_remove => :remove_admin_snippet,
    :user_index => :admin_users,
    :user_edit => :edit_admin_user,
    :user_new => :new_admin_user,
    :user_preferences => :edit_admin_preferences,
    :extension_index => :admin_extensions
  }.each do |old_route, new_route|
    define_method "#{old_route}_path" do |*args|
      warn_route_changed(old_route, new_route)
      send("#{new_route}_path", *args)
    end
    
    define_method "#{old_route}_url" do |*args|
      warn_route_changed(old_route, new_route)
      send("#{new_route}_url", *args)
    end
  end
  {
    :tag_reference => :tags, 
    :filter_reference => :filters
  }.each do |old_route, new_id|
    define_method "#{old_route}_path" do |*args|
      warn_route_changed("#{old_route}_path", "admin_references_path(:#{new_id})")
      args.unshift(new_id)
      admin_references_path(*args)
    end
    
    define_method "#{old_route}_url" do |*args|
      warn_route_changed("#{old_route}_url", "admin_references_url(:#{new_id})")
      args.unshift(new_id)
      admin_references_url(*args)
    end
  end
  
  [:clear_cache, :extension_update].each do |route|
    define_method "#{route}_path" do |*args|
      warn_route_removed(route)
      nil
    end
    
    define_method "#{route}_url" do |*args|
      warn_route_removed(route)
      nil
    end
  end
  
  private
  
  def warn_route_changed(old_route, new_route)
    warn("The named route '#{old_route}' is deprecated in Radiant #{Radiant::Version.to_s} and is now '#{new_route}'.  Please update your extension.")
  end

  def warn_route_removed(old_route)
    warn("The named route '#{old_route}' is deprecated in Radiant #{Radiant::Version.to_s} and has been removed.  Please update your extension.")
  end
end
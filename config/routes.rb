ActionController::Routing::Routes.draw do |map|

  # Admin Routes
  map.with_options(:controller => 'admin/welcome') do |welcome|
    welcome.admin          'admin',                              :action => 'index'
    welcome.welcome        'admin/welcome',                      :action => 'index'
    welcome.login          'admin/login',                        :action => 'login'
    welcome.logout         'admin/logout',                       :action => 'logout'
  end
  
  # Export Routes
  map.with_options(:controller => 'admin/export') do |export|
    export.export          'admin/export',                             :action => 'yaml'
    export.export_yaml     'admin/export/yaml',                        :action => 'yaml'
  end

  # Page Routes
  map.with_options(:controller => 'admin/page') do |page|
    page.page_index        'admin/pages',                        :action => 'index'
    page.page_edit         'admin/pages/edit/:id',               :action => 'edit'
    page.page_new          'admin/pages/:parent_id/child/new',   :action => 'new'
    page.homepage_new      'admin/pages/new/homepage',           :action => 'new',        :slug => '/', :breadcrumb => 'Home'
    page.page_remove       'admin/pages/remove/:id',             :action => 'remove'
    page.page_add_part     'admin/ui/pages/part/add',            :action => 'add_part'
    page.page_children     'admin/ui/pages/children/:id/:level', :action => 'children',   :level => '1'
    page.tag_reference     'admin/ui/pages/tag_reference',       :action => 'tag_reference'
    page.filter_reference  'admin/ui/pages/filter_reference',    :action => 'filter_reference'
    page.clear_cache       'admin/pages/cache/clear',            :action => 'clear_cache'    
  end

  # Layouts Routes
  map.with_options(:controller => 'admin/layout') do |layout|
    layout.layout_index    'admin/layouts',                      :action => 'index'
    layout.layout_edit     'admin/layouts/edit/:id',             :action => 'edit'
    layout.layout_new      'admin/layouts/new',                  :action => 'new'
    layout.layout_remove   'admin/layouts/remove/:id',           :action => 'remove'  
  end  
                       
  # Snippets Routes
  map.with_options(:controller => 'admin/snippet') do |snippet|
    snippet.snippet_index  'admin/snippets',                     :action => 'index'
    snippet.snippet_edit   'admin/snippets/edit/:id',            :action => 'edit'
    snippet.snippet_new    'admin/snippets/new',                 :action => 'new'
    snippet.snippet_remove 'admin/snippets/remove/:id',          :action => 'remove'
  end
                        
  # Users Routes
  map.with_options(:controller => 'admin/user') do |user|
    user.user_index        'admin/users',                        :action => 'index'
    user.user_edit         'admin/users/edit/:id',               :action => 'edit'
    user.user_new          'admin/users/new',                    :action => 'new'
    user.user_remove       'admin/users/remove/:id',             :action => 'remove'
    user.user_preferences  'admin/preferences',                  :action => 'preferences'
  end
  
  # Extension Routes
  map.with_options(:controller => 'admin/extension') do |extension|
    extension.extension_index  'admin/extensions',                :action => 'index'
    extension.extension_update 'admin/extensions/update',         :action => 'update'
  end
  
  # Site URLs
  map.with_options(:controller => 'site') do |site|
    site.homepage          '',                                   :action => 'show_page', :url => '/'
    site.not_found         'error/404',                          :action => 'not_found'
    site.error             'error/500',                          :action => 'error'

    # Everything else
    site.connect           '*url',                               :action => 'show_page'
  end
  
end
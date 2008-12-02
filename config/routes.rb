ActionController::Routing::Routes.draw do |map|

  # Admin RESTful Routes
  map.namespace :admin, :member => { :remove => :get } do |admin|
    admin.resources :pages do |pages|
      pages.resources :children, :controller => "pages"
    end
    admin.resources :layouts
    admin.resources :snippets
    admin.resources :users
  end

  map.namespace :admin do |admin|
    admin.resource :preferences
    admin.resources :extensions
    admin.resources :page_parts
    admin.resources :references
  end

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

  # Site URLs
  map.with_options(:controller => 'site') do |site|
    site.root                                                    :action => 'show_page', :url => '/'
    site.not_found         'error/404',                          :action => 'not_found'
    site.error             'error/500',                          :action => 'error'

    # Everything else
    site.connect           '*url',                               :action => 'show_page'
  end

end

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
  map.preview 'admin/preview', :controller => 'admin/pages', :action => 'preview', :conditions => {:method => [:post, :put]}

  map.namespace :admin do |admin|
    admin.resource :preferences
    admin.resource :configuration, :controller => 'configuration'
    # admin.resources :settings
    admin.resources :extensions, :only => :index
    admin.resources :page_parts
    admin.resources :page_fields
    admin.reference '/reference/:type.:format', :controller => 'references', :action => 'show', :conditions => {:method => :get}
  end

  # Admin Routes
  map.with_options(:controller => 'admin/welcome') do |welcome|
    welcome.admin          'admin',                              :action => 'index'
    welcome.welcome        'admin/welcome',                      :action => 'index'
    welcome.login          'admin/login',                        :action => 'login'
    welcome.logout         'admin/logout',                       :action => 'logout'
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

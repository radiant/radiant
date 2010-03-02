Radiant::Application.routes.draw do |map|
  # The priority is based upon order of creation:
  # first created -> highest priority.
  
  namespace :admin do
    resources :pages do
      resources :children, :controller => 'pages'
      member do
        get :remove
      end
    end
    resources :layouts do
      member do
        get :remove
      end
    end
    resources :snippets do
      member do
        get :remove
      end
    end
    resources :users do
      member do
        get :remove
      end
    end
    
    resource :preferences
    resources :extensions, :only => :index
    resources :page_parts
    match 'reference/:type(.:format)' => 'admin/references#show', :as => :reference
  end
  
  match 'admin' => 'admin/welcome#index', :as => :admin
  match 'admin/welcome' => 'admin/welcome#index', :as => :welcome
  match 'admin/login' => 'admin/welcome#login', :as => :login
  match 'admin/logout' => 'admin/welcome#logout', :as => :logout
  
  match 'admin/export' => 'admin/export#yaml', :as => :export
  match 'admin/export/yaml' => 'admin/export#yaml', :as => :export_yaml
  
  root :to => 'site#show_page'
  
  match 'error/404' => 'site#not_found', :as => :not_found
  match 'error/500' => 'site#error', :as => :error
  
  # main catch-all route
  match '*url' => 'site#show_page'
end

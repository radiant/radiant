Radiant::Engine.routes.draw do
  namespace :admin do
    resources :pages do
      resources :children, :controller => 'pages'
      member do
        get :remove
        post :preview
        put :preview
      end
    end
    resources :layouts do
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
    resource :configuration
    resources :extensions,  :only => :index
    resources :page_parts,  :only => :create
    resources :page_fields, :only => :create
    match 'reference/:type(.:format)' => 'radiant/references#show', :as => :reference
  end

  match 'admin' => 'radiant/welcome#index', :as => :admin
  match 'admin/welcome' => 'radiant/welcome#index', :as => :welcome
  match 'admin/login' => 'radiant/welcome#login', :as => :login
  match 'admin/logout' => 'radiant/welcome#logout', :as => :logout

  match 'admin/export' => 'radiant/export#yaml', :as => :export
  match 'admin/export/yaml' => 'radiant/export#yaml', :as => :export_yaml

  root :to => 'site#show_page'

  match 'error/404' => 'site#not_found', :as => :not_found
  match 'error/500' => 'site#error', :as => :error

  # main catch-all route
  match '*url' => 'site#show_page'
end

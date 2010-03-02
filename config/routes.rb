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
  end
  match 'admin/preview', :to => 'admin/pages#preview', :conditions => {:method => [:post, :put]}
  namespace :admin do
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
	resource :configuration, :to => 'configuration'
    resources :extensions, :only => :index
    resources :page_parts
	resources :page_fields
    match 'reference/:type(.:format)' => 'admin/references#show', :as => :reference
  end

  match 'admin' => 'admin/welcome#index', :as => :admin
  match 'admin/welcome' => 'admin/welcome#index', :as => :welcome
  match 'admin/login' => 'admin/welcome#login', :as => :login
  match 'admin/logout' => 'admin/welcome#logout', :as => :logout

  root :to => 'site#show_page'

  match 'error/404' => 'site#not_found', :as => :not_found
  match 'error/500' => 'site#error', :as => :error

  # main catch-all route
  match '*url' => 'site#show_page'
end

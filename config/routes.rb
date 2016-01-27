Radiant::Engine.routes.draw do
  namespace :admin do
    resources :pages do
      resources :children, controller: 'pages'
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
    resources :extensions,  only: :index
    resources :page_parts,  only: :create
    resources :page_fields, only: :create
    get 'reference/:type(.:format)' => 'radiant/references#show', as: :reference
  end

  get 'admin' => 'admin/welcome#index', as: :admin
  get 'admin/welcome' => 'admin/welcome#index', as: :welcome
  match 'admin/login' => 'admin/welcome#login', as: :login, via: [:get, :post]
  get 'admin/logout' => 'admin/welcome#logout', as: :logout

  root to: 'site#show_page'

  get 'error/404' => 'site#not_found', as: :not_found
  get 'error/500' => 'site#error', as: :error

  # main catch-all route
  get '*url' => 'site#show_page'
end

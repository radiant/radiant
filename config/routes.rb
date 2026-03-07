Rails.application.routes.draw do

  # Admin RESTful Routes
  namespace :admin do
    resources :pages do
      member do
        get :remove
      end
      resources :children, controller: "pages"
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
    resource :configuration, controller: "configuration"
    resources :extensions, only: :index
    resources :page_parts
    resources :page_fields
    get "reference/:type", to: "references#show", as: :reference
  end

  # Admin preview route
  match "admin/preview", to: "admin/pages#preview", via: [:post, :put], as: :preview

  # Admin welcome/login/logout routes
  get "admin",         to: "admin/welcome#index",  as: :admin_welcome_index
  get "admin/welcome", to: "admin/welcome#index",  as: :welcome
  get "admin/login",   to: "admin/welcome#login",  as: :login
  post "admin/login",  to: "admin/welcome#login"
  get "admin/logout",  to: "admin/welcome#logout", as: :logout

  # Site URLs
  root to: "site#show_page"
  get "error/404", to: "site#not_found", as: :not_found
  get "error/500", to: "site#error",     as: :error

  # Everything else — front-end catch-all (must be last)
  get "*url", to: "site#show_page", as: :page
end

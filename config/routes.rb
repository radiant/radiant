Rails.application.routes.draw do
  # Admin RESTful Routes
  namespace :admin do
    resources :pages do
      resources :children, controller: "pages"
      member { get :remove }
      collection { post :preview }
    end
    resources :layouts do
      member { get :remove }
    end
    resources :users do
      member { get :remove }
    end
    resource :preferences, only: [:show, :edit, :update]
    resource :configuration, controller: "configuration", only: [:show, :edit, :update]
    resources :extensions, only: :index
    resources :page_parts
    resources :page_fields
    get "reference/:type", to: "references#show", as: :reference, defaults: { format: :html }
  end

  # Admin welcome/login
  get  "admin/welcome", to: "admin/welcome#index", as: :welcome
  get  "admin/login",   to: "admin/welcome#login", as: :login
  post "admin/login",   to: "admin/welcome#login", as: :login_post
  get  "admin/logout",  to: "admin/welcome#logout", as: :logout
  get  "admin",         to: "admin/welcome#index"

  # Error pages
  get "error/404", to: "site#not_found"
  get "error/500", to: "site#error"

  # Front-end page serving (catch-all, must be last)
  root to: "site#show_page"
  get "*url", to: "site#show_page"
end

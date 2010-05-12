ActionController::Routing::Routes.draw do |map|
  map.namespace :admin do |admin|
    admin.resources :extensions, :only => :index
  end
end
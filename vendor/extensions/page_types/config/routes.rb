ActionController::Routing::Routes.draw do |map|
  map.namespace :admin do |admin|
    admin.page_types '/pages/:page_id/types', :controller => 'page_types', :action => 'index', :conditions => { :method => :get }
  end
end
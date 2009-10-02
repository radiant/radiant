# Uncomment this if you reference any of your controllers in activate
# require_dependency 'application_controller'

class LinksExtension < Radiant::Extension
  version "1.0"
  description "Describe your extension here"
  url "http://yourwebsite.com/links"
  
  # define_routes do |map|
  #   map.namespace :admin, :member => { :remove => :get } do |admin|
  #     admin.resources :links
  #   end
  # end
  
  def activate
    admin.nav[:content] << admin.nav_item(:links, "Links", "/admin/links")
  end
end

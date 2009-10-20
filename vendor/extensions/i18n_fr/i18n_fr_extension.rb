# Uncomment this if you reference any of your controllers in activate
# require_dependency 'application_controller'

class I18nFrExtension < Radiant::Extension
  version "1.0"
  description "Describe your extension here"
  url "http://yourwebsite.com/fr"
  
  # define_routes do |map|
  #   map.namespace :admin, :member => { :remove => :get } do |admin|
  #     admin.resources :fr
  #   end
  # end
  
  def activate
    # admin.nav[:content] << admin.nav_item(:fr, "I18n Fr", "/admin/fr"), :after => :pages
  end
end

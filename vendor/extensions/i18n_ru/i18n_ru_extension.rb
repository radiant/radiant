# Uncomment this if you reference any of your controllers in activate
# require_dependency 'application_controller'

class I18nRuExtension < Radiant::Extension
  version "1.0"
  description "Describe your extension here"
  url "http://yourwebsite.com/ru"
  
  # define_routes do |map|
  #   map.namespace :admin, :member => { :remove => :get } do |admin|
  #     admin.resources :ru
  #   end
  # end
  
  def activate
    # admin.nav[:content] << admin.nav_item(:ru, "I18n Ru", "/admin/ru"), :after => :pages
  end
end

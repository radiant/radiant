# Uncomment this if you reference any of your controllers in activate
# require_dependency 'application_controller'

class I18nDeExtension < Radiant::Extension
  version "1.0"
  description "Describe your extension here"
  url "http://yourwebsite.com/de"
  
  # define_routes do |map|
  #   map.namespace :admin, :member => { :remove => :get } do |admin|
  #     admin.resources :de
  #   end
  # end
  
  def activate
    # admin.nav[:content] << admin.nav_item(:de, "I18n De", "/admin/de"), :after => :pages
  end
end

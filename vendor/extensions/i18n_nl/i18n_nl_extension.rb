# Uncomment this if you reference any of your controllers in activate
# require_dependency 'application_controller'

class I18nNlExtension < Radiant::Extension
  version "1.0"
  description "Describe your extension here"
  url "http://yourwebsite.com/nl"
  
  # define_routes do |map|
  #   map.namespace :admin, :member => { :remove => :get } do |admin|
  #     admin.resources :nl
  #   end
  # end
  
  def activate
    # admin.nav[:content] << admin.nav_item(:nl, "I18n Nl", "/admin/nl"), :after => :pages
  end
end

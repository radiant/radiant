# Uncomment this if you reference any of your controllers in activate
# require_dependency 'application_controller'

class FooExtension < Radiant::Extension
  version "1.0"
  description "Describe your extension here"
  url "http://yourwebsite.com/foo"
  
  # define_routes do |map|
  #   map.namespace :admin, :member => { :remove => :get } do |admin|
  #     admin.resources :foo
  #   end
  # end
  
  def activate
    admin.nav[:content] << admin.nav_item(:foo, "Foo", "/admin/foo")
  end
end

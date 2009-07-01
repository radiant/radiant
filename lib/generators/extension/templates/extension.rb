# Uncomment this if you reference any of your controllers in activate
# require_dependency 'application_controller'

class <%= class_name %> < Radiant::Extension
  version "1.0"
  description "Describe your extension here"
  url "http://yourwebsite.com/<%= file_name %>"
  
  # define_routes do |map|
  #   map.namespace :admin, :member => { :remove => :get } do |admin|
  #     admin.resources :<%= file_name %>
  #   end
  # end
  
  def activate
    # admin.tabs.add "<%= extension_name %>", "/admin/<%= file_name %>", :after => "Layouts", :visibility => [:all]
  end
  
  def deactivate
    # admin.tabs.remove "<%= extension_name %>"
  end
  
end

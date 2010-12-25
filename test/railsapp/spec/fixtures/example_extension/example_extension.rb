# Uncomment this if you reference any of your controllers in activate
# require_dependency 'application'

class ExampleExtension < Radiant::Extension
  version "1.0"
  description "Describe your extension here"
  url "http://yourwebsite.com/example"
  
  # define_routes do |map|
  #   map.connect 'admin/example/:action', :controller => 'admin/example'
  # end
  
  def activate
    # admin.tabs.add "Example", "/admin/example", :after => "Layouts", :visibility => [:all]
  end
  
  def deactivate
    # admin.tabs.remove "Example"
  end
  
end
class BasicExtension < Radiant::Extension
  version "1.1"
  description "just a test"
  url "http://test.com"
  
  define_routes do |map|
    map.connect '/your/routing', :controller => 'basic_extension', :action => 'routing'
    # map.connect ':controller/:action'
  end
  
  def activate
    admin.tabs.add "Basic Extension Tab", "/admin/basic"
  end
  
  def deactivate
  end
end
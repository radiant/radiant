class BasicExtension < Radiant::Extension
  version "1.1"
  description "just a test"
  url "http://test.com"
  
  define_routes do |map|
    map.connect '/your/routing', :controller => 'basic_extension', :action => 'routing'
    # map.connect ':controller/:action'
  end
  
  def activate
    tab 'Content' do
      add_item("Basic Extension Tab", "/admin/basic", :before => 'Pages')
    end
  end
end
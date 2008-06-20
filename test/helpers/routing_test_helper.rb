module RoutingTestHelper
  
  def setup_custom_routes
    map = ActionController::Routing::RouteSet::Mapper.new(routes)
    map.connect ':controller/:action/:id'
    routes.named_routes.install
  end
  
  def teardown_custom_routes
    routes.reload
  end
  
  private
  
    def routes
      ActionController::Routing::Routes
    end
    
end
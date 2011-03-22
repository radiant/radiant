ActionController::Routing::Routes.draw do |map|
  map.with_options(:controller => 'admin/export') do |export|
    export.export       'admin/export',       :action => 'export'
    export.export_type  'admin/export/:type', :action => 'export'
  end
end
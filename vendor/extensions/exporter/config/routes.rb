ActionController::Routing::Routes.draw do |map|
  map.with_options(:controller => 'admin/export') do |export|
    export.export          'admin/export',                             :action => 'yaml'
    export.export_yaml     'admin/export/yaml',                        :action => 'yaml'
  end
end
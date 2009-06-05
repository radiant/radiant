require_dependency 'application_controller'

require File.dirname(__FILE__) + '/lib/url_additions'
include UrlAdditions

class PaperclippedExtension < Radiant::Extension
  version "0.8.0"
  description "Assets extension based on the lightweight Paperclip plugin."
  url "http://github.com/kbingman/paperclipped"
  
  define_routes do |map|
    
    # Main RESTful routes for Assets
    map.namespace :admin, :member => { :remove => :get }, :collection => { :refresh => :post } do |admin|
      admin.resources :assets
    end
    
    # Bucket routes
    map.with_options(:controller => 'admin/assets') do |asset|
      asset.add_bucket        "/admin/assets/:id/add",                   :action => 'add_bucket'
      # asset.refresh_assets    "/admin/assets/:id/refresh",               :action => 'regenerate_thumbnails'
      
      asset.clear_bucket      "/admin/assets/clear_bucket",              :action => 'clear_bucket'
      asset.reorder_assets    '/admin/assets/reorder/:id',               :action => 'reorder'
      asset.attach_page_asset '/admin/assets/attach/:asset/page/:page',  :action => 'attach_asset'
      asset.remove_page_asset '/admin/assets/remove/:asset/page/:page',  :action => 'remove_asset'
    end
  end
  
  def activate
    
    Radiant::AdminUI.send :include, AssetsAdminUI unless defined? admin.asset # UI is a singleton and already loaded
    admin.asset = Radiant::AdminUI.load_default_asset_regions

    %w{page}.each do |view|
      admin.send(view).edit.add :main, "/admin/assets/show_bucket_link", :before => "edit_header"
      admin.send(view).edit.add :main, "/admin/assets/assets_bucket", :after => "edit_buttons"
    end
    
    Page.class_eval {
      include PageAssetAssociations
      include AssetTags
    }

    # connect UserActionObserver with my models 
    UserActionObserver.instance.send :add_observer!, Asset 
    
    # This is just needed for testing if you are using mod_rails
    if Radiant::Config.table_exists? && Radiant::Config["assets.image_magick_path"]
      Paperclip.options[:image_magick_path] = Radiant::Config["assets.image_magick_path"]
    end
    
    admin.tabs.add "Assets", "/admin/assets", :after => "Snippets", :visibility => [:all]
  end
  
  def deactivate
    # admin.tabs.remove "Assets"
  end
  
end
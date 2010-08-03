require_dependency 'application_controller'

class PageTypesExtension < Radiant::Extension
  version "0.1"
  description "Adds a page-type select menu"
  url "http://github.com/radiant/radiant"
  
  def activate
    Admin::PagesController.send :include, PagesControllerExtensions
    Admin::PagesController.helper :page_types
    Page.send :include, PageExtensions
  end
end

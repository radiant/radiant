# Uncomment this if you reference any of your controllers in activate
# require_dependency 'application_controller'

class <%= class_name %> < Radiant::Extension
  version "1.0"
  description "Describe your extension here"
  url "<%= homepage %>"

  # define_routes do |map|
  #   map.namespace :admin, :member => { :remove => :get } do |admin|
  #     admin.resources :<%= file_name %>
  #   end
  # end
  
  def activate
    # tab 'Content' do
    #   add_item "<%= extension_name %>", "/admin/<%= file_name %>", :after => "Pages"
    # end
  end
end

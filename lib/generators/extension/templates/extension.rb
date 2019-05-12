# Uncomment this if you reference any of your controllers in activate
# require_dependency "application_controller"
require "radiant-<%= file_name %>-extension"

class <%= class_name %> < Radiant::Extension
  version     Radiant<%= class_name %>::VERSION
  description Radiant<%= class_name %>::DESCRIPTION
  url         Radiant<%= class_name %>::URL

  # See your config/routes.rb file in this extension to define custom routes

  extension_config do |config|
    # config is the Radiant.configuration object
  end

  def activate
    # tab 'Content' do
    #   add_item "<%= extension_name %>", "/admin/<%= file_name %>", :after => "Pages"
    # end
  end
end

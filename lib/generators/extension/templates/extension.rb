# Uncomment this if you reference any of your controllers in activate
# require_dependency 'application_controller'
require 'radiant-<%= file_name %>-extension/version'
class <%= class_name %> < Radiant::Extension
  version Radiant<%= class_name %>::VERSION
  description "Adds <%= file_name %> to Radiant."
  url "<%= homepage %>"
  
  # extension_config do |config|
  #   config.gem 'some-awesome-gem'
  #   config.after_initialize do
  #     run_something
  #   end
  # end

  # See your config/routes.rb file in this extension to define custom routes
  
  def activate
    # tab 'Content' do
    #   add_item "<%= extension_name %>", "/admin/<%= file_name %>", :after => "Pages"
    # end
  end
end

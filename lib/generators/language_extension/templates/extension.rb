# Uncomment this if you reference any of your controllers in activate
# require_dependency "application_controller"
require "radiant-<%= file_name %>_language_pack-extension"

class <%= class_name %> < Radiant::Extension
  version     Radiant<%= class_name %>::VERSION
  description Radiant<%= class_name %>::DESCRIPTION
  url         Radiant<%= class_name %>::URL

  def activate
  end
end
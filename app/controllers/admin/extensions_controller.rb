class Admin::ExtensionsController < ApplicationController
  require_role :admin,
    denied_url: {controller: "pages", action: "index"},
    denied_message: "You must have administrative privileges to perform this action."

  def index
    @template_name = 'index' # for Admin::RegionsHelper
    @extensions = Radiant::Extension.descendants.sort_by { |ext| ext.extension_name.downcase }
  end
end

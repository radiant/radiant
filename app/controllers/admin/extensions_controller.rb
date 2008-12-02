class Admin::ExtensionsController < ApplicationController
  def index
    @extensions = Radiant::Extension.descendants.sort_by { |e| e.extension_name }
  end
end

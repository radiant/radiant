class Admin::ExtensionsController < ApplicationController
  def index
    @template_name = 'index' # for Admin::RegionsHelper
    @extensions = Radiant::Extension.descendants.sort_by { |e| e.extension_name }
  end
end

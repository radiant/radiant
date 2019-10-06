class Admin::ExtensionsController < ApplicationController
  only_allow_access_to :index,
    :when => :admin,
    :denied_url => { :controller => 'pages', :action => 'index' },
    :denied_message => 'You must have administrative privileges to perform this action.'
    
  def index
    @template_name = 'index' # for Admin::RegionsHelper
    @extensions = Radiant::Extension.descendants.sort_by { |e| e.extension_name }
  end
end

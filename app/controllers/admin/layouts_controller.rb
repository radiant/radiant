class Admin::LayoutsController < Admin::ResourceController
  only_allow_access_to :index, :show, :new, :create, :edit, :update, :remove, :destroy,
    :when => [:developer, :admin],
    :denied_url => { :controller => 'page', :action => 'index' },
    :denied_message => 'You must have developer privileges to perform this action.'
end

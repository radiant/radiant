class Admin::LayoutsController < Admin::ResourceController
  only_allow_access_to :index, :show, :new, :create, :edit, :update, :remove, :destroy,
    :when => [:designer, :admin],
    :denied_url => { :controller => 'admin/pages', :action => 'index' },
    :denied_message => 'You must have designer privileges to perform this action.'

  def show
    respond_to do |format|
      format.xml { super }
      format.html { redirect_to edit_admin_layout_path(params[:id]) }
    end
  end
end

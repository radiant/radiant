class Admin::SnippetsController < Admin::ResourceController
  def show
    respond_to do |format|
      format.xml { super }
      format.html { redirect_to edit_admin_snippet_path(params[:id]) }
    end
  end
end

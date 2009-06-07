class Admin::SnippetsController < Admin::ResourceController
  def show
    redirect_to edit_admin_snippet_path(params[:id])
  end
end
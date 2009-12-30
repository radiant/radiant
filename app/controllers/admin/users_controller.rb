class Admin::UsersController < Admin::ResourceController
  only_allow_access_to :index, :show, :new, :create, :edit, :update, :remove, :destroy,
    :when => :admin,
    :denied_url => { :controller => 'pages', :action => 'index' },
    :denied_message => 'You must have administrative privileges to perform this action.'

  before_filter :ensure_deletable, :only => [:remove, :destroy]
  
  def show
    redirect_to edit_admin_user_path(params[:id])
  end
  
  def update
    user_params = params[model_symbol]
    if user_params && user_params['admin'] == false && model == current_user
      user_params.delete('admin')
      annouce_cannot_remove_self_from_admin_role
    end
    model.update_attributes!(user_params)
    response_for :update
  end
  
  def ensure_deletable
    if current_user.id.to_s == params[:id].to_s
      announce_cannot_delete_self
      redirect_to admin_users_url
    end
  end
  
  private
  
    def announce_cannot_delete_self
      flash[:error] = 'You cannot delete yourself.'
    end  
    
    def annouce_cannot_remove_self_from_admin_role
      flash[:error] = 'You cannot remove yourself from the admin role.'
    end
end

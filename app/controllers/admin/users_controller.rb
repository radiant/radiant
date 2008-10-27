class Admin::UsersController < Admin::ResourceController
  only_allow_access_to :index, :show, :new, :create, :edit, :update, :remove, :destroy,
    :when => :admin,
    :denied_url => { :controller => 'pages', :action => 'index' },
    :denied_message => 'You must have administrative privileges to perform this action.'

  before_filter :ensure_deletable, :only => [:remove, :destroy]
  
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
end

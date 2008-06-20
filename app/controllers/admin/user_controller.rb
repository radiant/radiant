class Admin::UserController < Admin::AbstractModelController
  model_class User
  
  only_allow_access_to :index, :new, :edit, :remove,
    :when => :admin,
    :denied_url => {:controller => 'page', :action => :index},
    :denied_message => 'You must have administrative privileges to perform this action.'
  
  def preferences
    @user = current_user
    if valid_params?
      handle_new_or_edit_post(
        :redirect_to => page_index_url,
        :saved_message => 'Your preferences have been saved.'
      )
    else
      announce_bad_data
    end
  end
  
  def remove
    if current_user.id.to_s == params[:id].to_s
      announce_cannot_delete_self
      redirect_to user_index_url
    else
      super
    end
  end
  
  private
  
    def announce_cannot_delete_self
      flash[:error] = 'You cannot delete yourself.'
    end
  
    def announce_bad_data
      flash[:error] = 'Bad form data.'
    end
    
    def valid_params?
      hash = (params[:user] || {}).symbolize_keys
      (hash.keys - [:password, :password_confirmation, :email]).size == 0
    end
end

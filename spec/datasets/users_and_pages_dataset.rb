class UsersAndPagesDataset < Dataset::Base
  uses :pages, :users
  
  def load
    UserActionObserver.current_user = users(:admin)
    Page.update_all "created_by_id = #{user_id(:admin)}, updated_by_id = #{user_id(:admin)}"
    create_page "No User"
  end
end
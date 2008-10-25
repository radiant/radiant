module Admin::UsersHelper
  def roles(user)
    roles = []
    roles << 'Administrator' if user.admin?
    roles << 'Developer' if user.developer?
    roles.join(', ')
  end
end

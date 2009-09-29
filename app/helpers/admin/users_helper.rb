module Admin::UsersHelper
  def roles(user)
    roles = []
    roles << 'Administrator' if user.admin?
    roles << 'Designer' if user.designer?
    roles.join(', ')
  end
end

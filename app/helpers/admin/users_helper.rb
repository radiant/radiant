module Admin::UsersHelper
  def roles(user)
    roles = []
    roles << I18n.t('views.users.admin') if user.admin?
    roles << I18n.t('views.users.designer') if user.designer?
    roles.join(', ')
  end
end

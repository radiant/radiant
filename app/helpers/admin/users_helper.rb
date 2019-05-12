module Admin::UsersHelper
  def roles(user)
    roles = []
    roles << I18n.t('admin') if user.admin?
    roles << I18n.t('designer') if user.designer?
    roles.join(', ')
  end
end

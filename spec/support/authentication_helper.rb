module AuthenticationHelper
  def login_as(user)
    login_user = user.is_a?(User) ? user : users(user)
    flunk "Can't login as non-existing user #{user.to_s}." unless login_user
    request.session['user_id'] = login_user.id
    login_user
  end
  
  def logout
    request.session['user_id'] = nil
  end
end
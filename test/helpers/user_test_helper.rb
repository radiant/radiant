module UserTestHelper
  VALID_USER_PARAMS = {
    :name => 'John Doe',
    :login => 'jdoe',
    :password => 'coolness',
    :password_confirmation => 'coolness',
    :email => 'jdoe@gmail.com'
  }
  
  def user_params(options = {})
    params = VALID_USER_PARAMS.dup
    params.merge!(:login => @user_login) if @user_login
    params.merge!(options)
  end
  
  def destroy_test_user(login = @user_login)
    while user = get_test_user(login) do
      user.destroy
    end
  end
  
  def get_test_user(login = @user_login)
    User.find_by_login(login)
  end
  
  def create_test_user(options = {})
    options[:login] ||= @user_login if @user_login
    user = User.new user_params(options)
    if user.save
      user
    else
      raise "user <#{user.inspect}> could not be saved"
    end
  end
end
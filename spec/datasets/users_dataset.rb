class UsersDataset < Dataset::Base
  
  def load
    create_user "Existing"
    create_user "Another"
    create_user "Admin", :admin => true
    create_user "Designer", :designer => true, :email => ''
    create_user "Non_admin", :admin => false
  end
  
  helpers do
    def create_user(name, attributes={})
      user = create_model :user, name.downcase.to_sym, user_attributes(attributes.update(:name => name))
      if user.nil?
        throw "Error creating user dataset for #{name}"
      end
    end
    
    def user_attributes(attributes={})
      name = attributes[:name]
      if name.nil?
        throw "name attribute is required"
      end
      
      attributes = { 
        :name => name,
        :email => "#{name.downcase}@example.com", 
        :login => name.downcase,
        :password => "password"
      }.merge(attributes)
      attributes[:password_confirmation] = attributes[:password]
      attributes
    end
    
    def user_params(options = {})
      {
        :name => 'John Doe',
        :login => 'jdoe',
        :password => 'password',
        :password_confirmation => 'password',
        :email => 'jdoe@gmail.com'
      }.merge(options)
    end
    
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
end

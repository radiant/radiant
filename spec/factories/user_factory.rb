FactoryGirl.define do
  factory :user do
    name 'User'
    email 'email@test.com'
    login 'user'
    password 'coolness'
    password_confirmation { password }
    
    factory :admin do
      name 'Admin'
      login 'admin'
      email 'admin@example.com'
      admin true
    end
  
    factory :designer do
      name 'Designer'
      login 'designer'
      email ''
      designer true
    end
  
    factory :non_admin do
      name 'Non Admin'
      login 'non_admin'
      admin false
    end
  end  
end
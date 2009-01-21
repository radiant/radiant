require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe 'Managing users' do
  dataset :users
  
  describe 'as non-admin' do
    before { login :existing }
    
    it 'should not allow listing' do
      navigate_to '/admin/users'
      response.should be_showing('/admin/pages')
      response.should have_tag('#error')
    end
    
    {:new => ['/admin/users/new', :get], :edit => ['/admin/users/1/edit', :get],
       :create => ['/admin/users', :post], :update => ['/admin/users/1', :put], 
       :destroy => ['/admin/users/1', :delete]}.each do |action, where|
      it "should not be allowed to #{where[1].to_s.upcase} to #{action}" do
        login :existing
        navigate_to *where
        response.should be_showing('/admin/pages')
        response.should have_tag('#error')
      end
    end
  end
  
  describe 'as admin' do
    def valid_user_attributes
      {
        :name => 'New Guy',
        :email => 'newguy@example.com',
        :login => 'new_guy',
        :password => 'password', :password_confirmation => 'password',
        :notes => 'Notes'
      }
    end
    
    before { login :admin }
    
    it 'should allow creating users' do
      navigate_to '/admin/users/new'
      lambda do
        submit_form :user => valid_user_attributes
      end.should change(User, :count)
    end
    
    it 'should display form errors' do
      navigate_to '/admin/users/new'
      lambda do
        submit_form :user => valid_user_attributes.merge(:login => nil)
      end.should_not change(User, :count)
      response.should have_tag('#error')
    end
    
    it 'should allow editing users' do
      user = User.create!(valid_user_attributes)
      navigate_to "/admin/users/#{user.id}/edit"
      submit_form :user => {:name => 'Old Guy'}
      user.reload.name.should == 'Old Guy'
    end
    
    it 'should allow removing users' do
      user = User.create!(valid_user_attributes)
      navigate_to "/admin/users/#{user.id}/remove"
      lambda do
        submit_form
      end.should change(User, :count).by(-1)
    end
    
    it 'should not allow admin to remove himself' do
      navigate_to "/admin/users/#{current_user.id}/remove"
      response.should have_tag('#error')
      
      lambda do
        submit_to "/admin/users/#{current_user.id}", {}, :delete
      end.should_not change(User, :count)
      response.should have_tag('#error')
    end
  end
end
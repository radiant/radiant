require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe 'Managing users' do
  scenario :users
  
  describe 'as non-admin' do
    it 'should not allow listing' do
      login :existing
      navigate_to '/admin/users'
      response.should be_showing('/admin/page')
      response.should have_tag('#error')
    end
    
    {:new => :get, :edit => :get, :create => :post, :update => :put, :destroy => :delete}.each do |action, verb|
      it "should not be allowed to #{action}" do
        login :existing
        params = {}
        params[:id] = '1' if verb != :get
        send verb, params
        response.should redirect_to('/admin/welcome')
      end
    end
  end
  
  describe 'as admin' do
    def valid_user_attributes
      {
        :name => 'New Guy',
        :email => 'newguy@nomail.net',
        :login => 'new_guy',
        :password => 'password', :password_confirmation => 'password',
        :notes => 'Notes'
      }
    end
    
    before { login :admin }
    
    it 'should allow creating users' do
      navigate_to '/admin/user/new'
      lambda do
        submit_form :user => valid_user_attributes
      end.should change(User, :count)
    end
    
    it 'should display form errors' do
      navigate_to '/admin/user/new'
      lambda do
        submit_form :user => {}
      end.should_not change(User, :count)
      response.should have_tag('#error')
    end
    
    it 'should allow editing users' do
      user = User.create!(valid_user_attributes)
      navigate_to "/admin/user/#{user.id}/edit"
      submit_form :user => {:name => 'Old Guy'}
      user.reload.name.should == 'Old Guy'
    end
    
    it 'should allow removing users'
    it 'should not allow admin to remove himself'
  end
end
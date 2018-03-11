require 'spec_helper'

describe User, "validations" do
  test_helper :user

  describe 'name' do

    let(:user){ User.new(user_params) }

    it 'is invalid when longer than 100 characters' do
      user.name = 'x' * 101
      expect(user.errors_on(:name)).to include('this must not be longer than 100 characters')
    end

    it 'is invalid when blank' do
      user.name = ''
      expect(user.errors_on(:name)).to include("this must not be blank")
    end

    it 'is valid when 100 characters or shorter' do
      user.name = 'x' * 100
      expect(user.errors).to be_blank
    end

  end

  describe 'email' do

    let(:user){ User.new(user_params) }

    it 'is invalid when longer than 255 characters' do
      user.email = ('x' * 247) + '@test.com'
      expect(user.errors_on(:email)).to include('this must not be longer than 255 characters')
    end

    it 'is valid when blank' do
      user.email = nil
      expect(user.errors_on(:email).size).to eq(0)
    end

    it 'is valid when 100 characters or shorter' do
      user.name = ('x' * 246) + '@test.com'
      expect(user.errors_on(:email)).to be_blank
    end

    it 'is invalid when in the incorrect format' do
      ['@test.com', 'test@', 'testtest.com', 'test@test', 'test me@test.com', 'test@me.c'].each do |address|
        user.email = address
        expect(user.errors_on(:email)).to include('this is not a valid e-mail address')
      end
    end

  end

  describe 'login' do

    let(:user){ User.new(user_params) }

    it 'is invalid when longer than 40 characters' do
      user.login = 'x' * 41
      expect(user.error_on(:login).size).to eq(1)
    end

    it 'is valid when blank' do
      user.login = nil
      expect(user.errors_on(:login).size).to eq(0)
    end

    it 'is invalid when shorter than 3 characters' do
      user.login = 'xx'
      expect(user.error_on(:login).size).to eq(1)
    end

    it 'is valid when 40 characters or shorter' do
      user.login = 'x' * 40
      expect(user.errors_on(:login).size).to eq(0)
    end

    it 'is invalid if another User exists with the same login' do
      user.save!
      second = User.new(user_params)
      expect(second.login).to be_eql(user.login)
      expect(second.errors_on(:login).size).to eq(1)
    end
  end

  describe 'password' do

    let(:user){ User.new(user_params) }

    it 'is invalid when longer than 40 characters' do
      user.password = 'x' * 41
      expect(user.errors_on(:password)).to include('this must not be longer than 40 characters')
    end

    it 'is invalid when shorter than 5 characters' do
      user.password = 'x' * 4
      expect(user.errors_on(:password)).to include('this must be at least 5 characters long')
    end

    it 'is valid when 40 characters or shorter' do
      user.password = 'x' * 40
      expect(user.errors_on(:password).size).to eq(0)
    end

    it 'ensures the confirmation matches' do
      user.password = 'test'
      user.password_confirmation = 'not correct'
      expect(user.errors_on(:password_confirmation)).to include("doesn't match Password")
    end
  end


  describe "self.unprotected_attributes" do
    it "should be an array of [:name, :email, :login, :password, :password_confirmation, :locale]" do
      # Make sure we clean up after anything set in another spec
      User.instance_variable_set(:@unprotected_attributes, nil)
      expect(User.unprotected_attributes).to be_eql([:name, :email, :login, :password, :password_confirmation, :locale])
    end
  end
  describe "self.unprotected_attributes=" do
    it "should set the @@unprotected_attributes variable to the given array" do
      User.unprotected_attributes = [:password, :email, :other]
      expect(User.unprotected_attributes).to be_eql([:password, :email, :other])
    end
  end
end

describe User do
  test_helper :user

  let(:user){ User.new(user_params.merge(password: 'password')) }

  it 'should save password encrypted' do
    user.password_confirmation = user.password = 'test_password'
    user.save!
    expect(user.password).to be_eql(user.sha1('test_password'))
  end

  it 'should save existing but empty password' do
    user.save!
    user.password_confirmation = user.password = ''
    user.save!
    expect(user.password).to be_eql(user.sha1('password'))
  end

  it 'should save existing but different password' do
    user.save!
    user.password_confirmation = user.password = 'cool beans'
    user.save!
    expect(user.password).to be_eql(user.sha1('cool beans'))
  end

  it 'should save existing but same password' do
    user.save! && user.save!
    expect(user.password).to be_eql(user.sha1('password'))
  end

  it "should create a salt when encrypting the password" do
    expect(user.salt).to be_nil
    user.send(:encrypt_password)
    expect(user.salt).to_not be_nil
    expect(user.password).to be_eql(user.sha1('password'))
  end

  describe ".remember_me" do
    before do
      allow(Radiant::Config).to receive(:[]).with('session_timeout').and_return(2.weeks)
      user.save
      user.remember_me
      user.reload
    end

    it "should remember user" do
      expect(user.session_token).to_not be_nil
    end
  end

  describe ".forget_me" do

    before do
      allow(Radiant::Config).to receive(:[]).with('session_timeout').and_return(2.weeks)
      user.save
      user.remember_me
    end

    it "should forget user" do
      user.forget_me
      expect(user.session_token).to be_nil
    end
  end

end

describe User, "class methods" do

  let(:existing){ FactoryGirl.build(:user, login: 'existing', email: 'existing@example.com', password: 'password') }

  it 'should authenticate with correct username and password' do
    existing.save!
    user = User.authenticate('existing', 'password')
    expect(user).to be_eql(existing)
  end

  it 'should authenticate with correct email and password' do
    existing.save!
    user = User.authenticate('existing@example.com', 'password')
    expect(user).to be_eql(existing)
  end

  it 'should not authenticate with bad password' do
    expect(User.authenticate('existing', 'bad password')).to be_nil
  end

  it 'should not authenticate with bad user' do
    expect(User.authenticate('nonexisting', 'password')).to be_nil
  end
end

describe User, "roles" do

  let(:admin){ FactoryGirl.build(:user, admin: true) }
  let(:designer){ FactoryGirl.build(:user, designer: true) }
  let(:existing){ FactoryGirl.build(:user) }

  it "should not have a non-existent role" do
    expect(existing.has_role?(:foo)).to be false
  end

  it "should not have a role for which the corresponding method returns false" do
    expect(existing.has_role?(:designer)).to be false
    expect(existing.has_role?(:admin)).to be false
  end

  it "should have a role for which the corresponding method returns true" do
    expect(designer.has_role?(:designer)).to be true
    expect(admin.has_role?(:admin)).to be true
  end
end
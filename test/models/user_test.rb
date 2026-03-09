require "test_helper"

class UserTest < ActiveSupport::TestCase
  # Validations

  test "validates presence of name" do
    user = User.new(login: "newuser", password: "password", password_confirmation: "password")
    assert_not user.valid?
    assert user.errors[:name].any?
  end

  test "validates presence of login" do
    user = User.new(name: "Test", password: "password", password_confirmation: "password")
    assert_not user.valid?
    assert user.errors[:login].any?
  end

  test "validates presence of password on create" do
    user = User.new(name: "Test", login: "newuser")
    assert_not user.valid?
    assert user.errors[:password].any?
  end

  test "validates uniqueness of login" do
    user = User.new(name: "Dupe", login: users(:existing).login, password: "password", password_confirmation: "password")
    assert_not user.valid?
    assert user.errors[:login].any?
  end

  test "validates confirmation of password" do
    user = User.new(name: "Test", login: "newuser", password: "password", password_confirmation: "wrong")
    assert_not user.valid?
    assert user.errors[:password_confirmation].any?
  end

  test "validates length of login" do
    user = User.new(name: "Test", login: "ab", password: "password", password_confirmation: "password")
    assert_not user.valid?
    assert user.errors[:login].any?
  end

  test "validates length of password" do
    user = User.new(name: "Test", login: "newuser", password: "ab", password_confirmation: "ab")
    assert_not user.valid?
    assert user.errors[:password].any?
  end

  test "validates format of email" do
    user = User.new(name: "Test", login: "newuser", password: "password", password_confirmation: "password", email: "invalid")
    assert_not user.valid?
    assert user.errors[:email].any?
  end

  test "allows blank email" do
    user = User.new(name: "Test", login: "newuser", password: "password", password_confirmation: "password", email: "")
    user.valid?
    assert_empty user.errors[:email]
  end

  test "allows valid email" do
    user = User.new(name: "Test", login: "newuser", password: "password", password_confirmation: "password", email: "test@example.com")
    user.valid?
    assert_empty user.errors[:email]
  end

  # Authentication

  test "authenticate with valid credentials" do
    user = User.authenticate("existing", "password")
    assert_equal users(:existing), user
  end

  test "authenticate with email" do
    user = User.authenticate("existing@example.com", "password")
    assert_equal users(:existing), user
  end

  test "authenticate with invalid password" do
    assert_nil User.authenticate("existing", "wrong")
  end

  test "authenticate with nonexistent login" do
    assert_nil User.authenticate("nonexistent", "password")
  end

  # Password hashing

  test "uses bcrypt for password storage" do
    user = User.create!(name: "New User", login: "newuser", password: "password", password_confirmation: "password")
    assert user.password_digest.present?
    assert user.authenticate("password")
    assert_not user.authenticate("wrong")
  end

  test "can update user without changing password" do
    user = users(:existing)
    user.update!(name: "Updated Name")
    assert_equal "Updated Name", user.reload.name
    assert User.authenticate("existing", "password")
  end

  # Roles

  test "has_role? admin" do
    assert users(:admin).has_role?(:admin)
    assert_not users(:existing).has_role?(:admin)
  end

  test "has_role? designer" do
    assert users(:designer).has_role?(:designer)
    assert_not users(:existing).has_role?(:designer)
  end
end

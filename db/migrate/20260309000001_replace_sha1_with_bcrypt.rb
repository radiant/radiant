class ReplaceSha1WithBcrypt < ActiveRecord::Migration[8.0]
  def up
    add_column :users, :password_digest, :string

    # Migrate existing SHA1 passwords to bcrypt.
    # We can't reverse SHA1, so all users get a known password.
    # In production, you'd force password resets instead.
    rows = ActiveRecord::Base.connection.select_all("SELECT id FROM users")
    rows.each do |row|
      digest = BCrypt::Password.create("password")
      execute "UPDATE users SET password_digest = #{connection.quote(digest)} WHERE id = #{row['id']}"
    end

    remove_column :users, :password
    remove_column :users, :salt
    remove_column :users, :session_token
  end

  def down
    add_column :users, :password, :string, limit: 40
    add_column :users, :salt, :string
    add_column :users, :session_token, :string
    remove_column :users, :password_digest
  end
end

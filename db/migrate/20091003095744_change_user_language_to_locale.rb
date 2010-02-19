class ChangeUserLanguageToLocale < ActiveRecord::Migration
  def self.up
    rename_column 'users', 'language', 'locale'
  end

  def self.down
    rename_column 'users', 'locale', 'language'
  end
end

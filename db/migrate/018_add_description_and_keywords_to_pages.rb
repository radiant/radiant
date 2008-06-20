class AddDescriptionAndKeywordsToPages < ActiveRecord::Migration
  def self.up
    add_column :pages, :description, :string
    add_column :pages, :keywords, :string
  end

  def self.down
    remove_column :pages, :keywords
    remove_column :pages, :description
  end
end

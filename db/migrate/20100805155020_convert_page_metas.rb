class ConvertPageMetas < ActiveRecord::Migration
  def self.up
    Page.all.each do |page|
      page.fields.create(:name => 'Keywords', :content => page.keywords)
      page.fields.create(:name => 'Description', :content => page.description)
    end
    remove_column :pages, :keywords
    remove_column :pages, :description
  end

  def self.down
    add_column :pages, :description, :string
    add_column :pages, :keywords, :string
  end
end

class ConvertPageMetas < ActiveRecord::Migration
  def self.up
    # following add and remove column enables running this migration 
    # when upgrading radiant with allowed_children_cache added to Page model
    add_column :pages, :allowed_children_cache, :text
    Page.all.each do |page|
      page.fields.create(:name => 'Keywords', :content => page.keywords)
      page.fields.create(:name => 'Description', :content => page.description)
    end
    remove_column :pages, :keywords
    remove_column :pages, :description
    remove_column :pages, :allowed_children_cache
  end

  def self.down
    add_column :pages, :description, :string
    add_column :pages, :keywords, :string
    Page.all.each do |page|
      page.description = page.field('description').content
      page.keywords = page.field('keywords').content
      page.save
    end
  end
end

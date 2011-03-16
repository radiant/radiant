Cucumber::Rails::World.class_eval do
  dataset :users, :config, :pages, :layouts, :pages_with_layouts, :snippets, :users_and_pages, :file_not_found, :markup_pages
end

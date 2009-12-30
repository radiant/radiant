Cucumber::Rails::World.class_eval do
  include Dataset
  datasets_directory "#{RADIANT_ROOT}/spec/datasets"
  self.datasets_database_dump_path = "#{Rails.root}/tmp/dataset"

  dataset :config, :pages_with_layouts, :snippets, :users_and_pages, :file_not_found, :markup_pages
end

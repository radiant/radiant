require 'dataset'

Cucumber::Rails::World.class_eval do
  include Dataset
  datasets_directory "#{Rails.root}/spec/datasets"
  self.datasets_database_dump_path = "#{Rails.root}/tmp/dataset"
end

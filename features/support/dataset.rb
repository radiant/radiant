require 'cucumber/rails/world'
require 'dataset'

Cucumber::Rails::World.class_eval do
  include Dataset
  radiant_dataset_path = "#{RADIANT_ROOT}/spec/datasets"
  local_extension_paths = $LOAD_PATH.select{|p| p =~ /vendor\/extensions\/\w+[^\/]$/ }
  gem_extension_paths = $LOAD_PATH.select{|p| p =~ /gems\/radiant/ }
  dataset_paths = (local_extension_paths + gem_extension_paths).map{|p| p << '/spec/datasets' } << radiant_dataset_path
  
  Dataset::Resolver.default = Dataset::DirectoryResolver.new(*dataset_paths)
  self.datasets_database_dump_path = "#{Rails.root}/tmp/dataset"
end

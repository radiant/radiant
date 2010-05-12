# Sets up the Rails environment for Cucumber
ENV["RAILS_ENV"] = "test"
# Extension root
extension_env = File.expand_path(File.dirname(__FILE__) + '/../../../../../config/environment')
require extension_env+'.rb'

require 'cucumber/formatter/unicode' # Remove this line if you don't want Cucumber Unicode support
require 'cucumber/rails/rspec'
require 'cucumber/rails/world'
require 'cucumber/rails/active_record'
require 'cucumber/web/tableish'

Dir.glob(File.join(RADIANT_ROOT, "features", "**", "*.rb")).each {|step| require step}
 
Cucumber::Rails::World.class_eval do
  include Dataset
  datasets_directory "#{RADIANT_ROOT}/spec/datasets"
  Dataset::Resolver.default = Dataset::DirectoryResolver.new("#{RADIANT_ROOT}/spec/datasets", File.dirname(__FILE__) + '/../../spec/datasets', File.dirname(__FILE__) + '/../datasets')
  self.datasets_database_dump_path = "#{Rails.root}/tmp/dataset"
  
  # dataset :extension_manager
end
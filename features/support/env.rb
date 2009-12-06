# Sets up the Rails environment for Cucumber
ENV["RAILS_ENV"] ||= "test"
rails_env = File.expand_path(Dir.pwd + '/config/environment')
require rails_env if File.exist?(rails_env+'.rb')
require 'cucumber/rails/world'

# Comment out the next line if you don't want Cucumber Unicode support
require 'cucumber/formatter/unicode'

# Comment out the next line if you don't want transactions to
# open/roll back around each scenario
# Cucumber::Rails.use_transactional_fixtures

# Comment out the next line if you want Rails' own error handling
# (e.g. rescue_action_in_public / rescue_responses / rescue_from)
Cucumber::Rails.bypass_rescue

require 'webrat'
require 'cucumber/webrat/element_locator' # Lets you do table.diff!(element_at('#my_table_or_dl_or_ul_or_ol').to_table)

Webrat.configure do |config|
  config.mode = :rails
end

require 'cucumber/rails/rspec'
require 'webrat/core/matchers'
require 'dataset'
 
Cucumber::Rails::World.class_eval do
  include Dataset
  datasets_directory "#{RADIANT_ROOT}/spec/datasets"
  self.datasets_database_dump_path = "#{Rails.root}/tmp/dataset"

  dataset :config, :pages_with_layouts, :snippets, :users_and_pages, :file_not_found, :markup_pages
end

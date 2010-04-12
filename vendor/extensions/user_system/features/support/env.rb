# Sets up the Rails environment for Cucumber
ENV["RAILS_ENV"] = "test"
# Extension root
extension_env = File.expand_path(File.dirname(__FILE__) + '/../../../../../config/environment')
require extension_env+'.rb'

require 'cucumber/rails/world'

Dir.glob(File.join(File.dirname(__FILE__) + '..','..','..','..','..','features','**','*.rb')).each { |support| require support}
Dir.glob(File.join(RADIANT_ROOT, "features", "**", "*.rb")).each {|step| require step}
 
Cucumber::Rails::World.class_eval do
  # dataset :login_system
end
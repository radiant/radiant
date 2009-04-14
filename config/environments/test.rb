# Settings specified here will take precedence over those in config/environment.rb

# The test environment is used exclusively to run your application's
# test suite.  You never need to work with it otherwise.  Remember that
# your test database is "scratch space" for the test suite and is wiped
# and recreated between test runs.  Don't rely on the data there!
config.cache_classes = true

# ensure test extensions are loaded
# test_extension_dir = File.join(File.expand_path(RADIANT_ROOT), 'test', 'fixtures', 'extensions')
# config.extension_paths.unshift test_extension_dir
# config.extension_paths.uniq!
# if !config.extensions.include?(:all)
#   config.extensions.concat(Dir["#{test_extension_dir}/*"].sort.map {|x| File.basename(x).sub(/^\d+_/,'')})
#   config.extensions.uniq!
# end

# Log error messages when you accidentally call methods on nil.
config.whiny_nils    = true

# Show full error reports and disable caching
config.action_controller.consider_all_requests_local = true
config.action_controller.perform_caching             = false
ResponseCache.defaults[:perform_caching]             = false

# Disable request forgery protection in test environment
config.action_controller.allow_forgery_protection    = false

# Tell ActionMailer not to deliver emails to the real world.
# The :test delivery method accumulates sent emails in the
# ActionMailer::Base.deliveries array.
config.action_mailer.delivery_method = :test

config.gem "rspec", :version => "1.2.2", :lib => false
config.gem "rspec-rails", :version => "1.2.2", :lib => false
config.gem "webrat", :version => "~>0.4.4", :lib => false
config.gem "cucumber", :version => "~>0.2.3", :lib => false
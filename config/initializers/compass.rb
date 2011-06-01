require 'fileutils'
FileUtils.mkdir_p(Rails.root.join("tmp", "stylesheets"))

Sass::Plugin.options[:template_location] = (Rails.root + 'public' + 'stylesheets' + 'sass').to_s

require 'compass'
require 'compass/app_integration/rails'
Compass::AppIntegration::Rails.initialize!

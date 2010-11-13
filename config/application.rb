require File.expand_path('../boot', __FILE__)
require 'rails/all'

# Auto-require default libraries and those for the current Rails environment.
Bundler.require(:default, Rails.env) if defined?(Bundler)

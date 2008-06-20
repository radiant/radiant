require File.expand_path(File.dirname(__FILE__) + "/../testing/environment")
TESTING_ENVIRONMENTS[TESTING_ENVIRONMENT].load(DATABASE_ADAPTER)
require "models"
require "spec"
require "spec/rails"
require "scenarios"

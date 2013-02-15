unless defined? RADIANT_ROOT
  ENV["RAILS_ENV"] = "test"
  case
  when ENV["RADIANT_ENV_FILE"]
    require ENV["RADIANT_ENV_FILE"]
  when File.dirname(__FILE__) =~ %r{vendor/radiant/vendor/extensions}
    require "#{File.expand_path(File.dirname(__FILE__) + "/../../../../../../")}/config/environment"
  else
    require "#{File.expand_path(File.dirname(__FILE__) + "/../../../../")}/config/environment"
  end
end
require "#{RADIANT_ROOT}/spec/spec_helper"

Dataset::Resolver.default << (File.dirname(__FILE__) + "/datasets")
# Include any datasets from loaded extensions
Radiant::Extension.descendants.each do |extension|
  if File.directory?(extension.root + "/spec/datasets")
    Dataset::Resolver.default << (extension.root + "/spec/datasets")
  end
end

if File.directory?(File.dirname(__FILE__) + "/matchers")
  Dir[File.dirname(__FILE__) + "/matchers/*.rb"].each {|file| require file }
end

Spec::Runner.configure do |config|
  # config.use_transactional_fixtures = true
  # config.use_instantiated_fixtures  = false
  # config.fixture_path = RAILS_ROOT + '/spec/fixtures'

  # You can declare fixtures for each behaviour like this:
  #   describe "...." do
  #     fixtures :table_a, :table_b
  #
  # Alternatively, if you prefer to declare them only once, you can
  # do so here, like so ...
  #
  #   config.global_fixtures = :table_a, :table_b
  #
  # If you declare global fixtures, be aware that they will be declared
  # for all of your examples, even those that don't use them.
end
require File.dirname(__FILE__) + "/extension_generators_spec_helper"

describe "ExtensionGenerator with normal options" do
  include GeneratorSpecHelperMethods
  it_should_behave_like "all generators"

  before(:each) do
    FileUtils.cp_r File.join(BASE_ROOT, 'lib/generators/extension'),  File.join(RADIANT_ROOT, 'vendor/generators')
    git_config = {'user.name' => 'Ext Author', 'user.email' => 'ext@radiantcms.org', 'github.user' => 'extauthor'}
    allow(Git).to receive(:global_config).and_return git_config
    run_generator('extension', %w(Sample))
  end
  
  it "should generate README file" do
    expect('vendor/extensions/sample').to have_generated_file('README.md')
  end
  
  it "should generate a Rakefile" do
    expect('vendor/extensions/sample').to have_generated_file('Rakefile') do |body|
      expect(body).to match(/Spec::Rake::SpecTask\.new\(:spec\)/)
    end
  end
  
  it "should generate a config/routes.rb file" do
    expect('vendor/extensions/sample').to have_generated_file('config/routes.rb') do |body|
      expect(body).to match(/ActionController::Routing::Routes.draw do \|map\|((\n|\s*.*\n)*)\s+\# end/)
    end
  end
  
  it "should generate extension init file" do
    expect('vendor/extensions/sample').to have_generated_class('sample_extension', 'Radiant::Extension') do |body|
      expect(body).to match(%r(version     RadiantSampleExtension::VERSION))
      expect(body).to match(%r(description RadiantSampleExtension::DESCRIPTION))
      expect(body).to match(%r(url         RadiantSampleExtension::URL))
      expect(body).to match(/extension_config do \|config\|((\n|\s*.*\n)*)\s+\# end/)
      expect(body).to have_method('activate')
    end
  end
  
  it "should require the module" do
    expect('vendor/extensions/sample').to have_generated_file('sample_extension.rb') do |body|
      expect(body).to match(%r(require "radiant-sample-extension"))
    end
  end

  it "should generate extension Rake tasks file" do
    expect('vendor/extensions/sample').to have_generated_file('lib/tasks/sample_extension_tasks.rake') do |body|
      expect(body).to match(r = /namespace :radiant do\n  namespace :extensions do\n    namespace :sample do\n((\n|\s*.*\n)*)    end\n  end\nend/)
      tasks = body.match(r)[1]
      expect(tasks).to match(/task migrate: :environment do\n((\n|\s*.*\n)*)\s+end/)
      expect(tasks).to match(/task update: :environment do\n((\n|\s*.*\n)*)\s+end/)
    end
  end

  it "should populate radiant-sample-extension.gemspec with gem info" do
    expect('vendor/extensions/sample').to have_generated_file('radiant-sample-extension.gemspec') do |body|
      expect(body).to match(%r(s.name        = "radiant-sample-extension"))
      expect(body).to match(%r(s.email       = RadiantSampleExtension::EMAIL))
      expect(body).to match(%r(s.homepage    = RadiantSampleExtension::URL))
      expect(body).to match(%r(s.authors     = RadiantSampleExtension::AUTHORS))
      expect(body).to match(%r(s.description = RadiantSampleExtension::DESCRIPTION))
    end
  end
  
  it "should populate radiant-sample-extension.rb with module namespace" do
    expect('vendor/extensions/sample').to have_generated_file('lib/radiant-sample-extension.rb') do |body|
      expect(body).to match(%r(module RadiantSampleExtension))
      expect(body).to match(%r(VERSION     = "1\.0\.0"))
      expect(body).to match(%r(SUMMARY     = "Sample for Radiant CMS"))
      expect(body).to match(%r(DESCRIPTION = "Makes Radiant better by adding sample!"))
      expect(body).to match(%r(AUTHORS     = \["Ext Author"\]))
      expect(body).to match(%r(EMAIL       = \["ext@radiantcms.org"\]))
      expect(body).to match(%r(URL         = "http://github.com/extauthor/radiant-sample-extension"))
    end
  end
  
  it "should generate extension lib directory" do
    expect('vendor/extensions/sample').to have_generated_directory('lib')
  end

  it "should generate extension controllers directory" do
    expect('vendor/extensions/sample').to have_generated_directory('app/controllers')
  end
  
  it "should generate extension helpers directory" do
    expect('vendor/extensions/sample').to have_generated_directory('app/helpers')
  end
  
  it "should generate extension models directory" do
    expect('vendor/extensions/sample').to have_generated_directory('app/models')
  end
  
  it "should generate extension views directory" do
    expect('vendor/extensions/sample').to have_generated_directory('app/views')
  end
  
  it "should generate extension views directory" do
    expect('vendor/extensions/sample').to have_generated_directory('db/migrate')
  end
  
  it "should generate extension controllers spec directory" do
    expect('vendor/extensions/sample').to have_generated_directory('spec/controllers')
  end
  
  it "should generate extension helpers spec directory" do
    expect('vendor/extensions/sample').to have_generated_directory('spec/helpers')
  end
  
  it "should generate extension models spec directory" do
    expect('vendor/extensions/sample').to have_generated_directory('spec/models')
  end
  
  it "should generate extension views spec directory" do
    expect('vendor/extensions/sample').to have_generated_directory('spec/views')
  end
  
  it "should generate extension spec helper file" do
    expect('vendor/extensions/sample').to have_generated_file('spec/spec_helper.rb')
  end
  
  it "should generate extension spec opts file" do
    expect('vendor/extensions/sample').to have_generated_file('spec/spec.opts')
  end
  
  it "should generate extension cucumber.yml file" do
    expect('vendor/extensions/sample').to have_generated_file('cucumber.yml')
  end
  
  it "should generate extension config directory" do
    expect('vendor/extensions/sample').to have_generated_directory('config')
  end
  
  it "should generate extension routes.rb file" do
    expect('vendor/extensions/sample').to have_generated_file('config/routes.rb')
  end
  
  it "should generate extension locales directory" do
    expect('vendor/extensions/sample').to have_generated_directory('config/locales')
  end
  
  it "should generate extension en.yml file" do
    expect('vendor/extensions/sample').to have_generated_file('config/locales/en.yml')
  end
  
  it "should generate extension features support directory" do
    expect('vendor/extensions/sample').to have_generated_directory('features/support')
  end
  
  it "should generate extension features step_definitions directory" do
    expect('vendor/extensions/sample').to have_generated_directory('features/step_definitions/admin')
  end
  
  after(:each) do
    FileUtils.rm_rf Dir["#{RADIANT_ROOT}/vendor/extensions/*"]
    FileUtils.rm_rf Dir["#{RADIANT_ROOT}/vendor/generators/*"]
  end
end

describe "ExtensionGenerator with test-unit option" do
  include GeneratorSpecHelperMethods
  it_should_behave_like "all generators"
  
  before(:each) do
    allow(Git).to receive(:global_config).and_return({})
    FileUtils.cp_r File.join(BASE_ROOT, 'lib/generators/extension'),  File.join(RADIANT_ROOT, 'vendor/generators')
    run_generator('extension', %w(Sample --with-test-unit))
  end
  
  it "should generate README file" do
    expect('vendor/extensions/sample').to have_generated_file('README.md')
  end
  
  it "should generate Rake file" do
    expect('vendor/extensions/sample').to have_generated_file('Rakefile') do |body|
      expect(body).to match(/Rake::TestTask\.new\(:test\)/)
    end
  end
  
  it "should generate extension init file" do
    expect('vendor/extensions/sample').to have_generated_class('sample_extension', 'Radiant::Extension') do |body|
      expect(body).to match(%r(version     RadiantSampleExtension::VERSION))
      expect(body).to match(%r(description RadiantSampleExtension::DESCRIPTION))
      expect(body).to match(%r(url         RadiantSampleExtension::URL))
      expect(body).to have_method('activate')
    end
  end
  
  it "should require the module" do
    expect('vendor/extensions/sample').to have_generated_file('sample_extension.rb') do |body|
      expect(body).to match(%r(require "radiant-sample-extension"))
    end
  end

  it "should generate extension Rake tasks file" do
    expect('vendor/extensions/sample').to have_generated_file('lib/tasks/sample_extension_tasks.rake') do |body|
      expect(body).to match(r = /namespace :radiant do\n  namespace :extensions do\n    namespace :sample do\n((\n|\s*.*\n)*)    end\n  end\nend/)
      tasks = body.match(r)[1]
      expect(tasks).to match(/task migrate: :environment do\n((\n|\s*.*\n)*)\s+end/)
      expect(tasks).to match(/task update: :environment do\n((\n|\s*.*\n)*)\s+end/)
    end
  end
  
  it "should generate extension controllers directory" do
    expect('vendor/extensions/sample').to have_generated_directory('app/controllers')
  end
  
  it "should generate extension helpers directory" do
    expect('vendor/extensions/sample').to have_generated_directory('app/helpers')
  end
  
  it "should generate extension models directory" do
    expect('vendor/extensions/sample').to have_generated_directory('app/models')
  end
  
  it "should generate extension views directory" do
    expect('vendor/extensions/sample').to have_generated_directory('app/views')
  end
  
  it "should generate extension views directory" do
    expect('vendor/extensions/sample').to have_generated_directory('db/migrate')
  end
  
  it "should generate extension functional test directory" do
    expect('vendor/extensions/sample').to have_generated_directory('test/functional')
  end
  
  it "should generate extension test fixtures directory" do
    expect('vendor/extensions/sample').to have_generated_directory('test/fixtures')
  end
  
  it "should generate extension test unit directory" do
    expect('vendor/extensions/sample').to have_generated_directory('test/unit')
  end
  
  it "should generate extension test helper file" do
    expect('vendor/extensions/sample').to have_generated_file('test/test_helper.rb') do |body|
      expect(body).to match(/require 'test\/unit'/)
      expect(body).to match(/class ActiveSupport::TestCase\n((\n|\s*.*\n)*)end/)
    end
  end
  
  it "should generate extension functional test file" do
    expect('vendor/extensions/sample').to have_generated_file('test/functional/sample_extension_test.rb')
  end
  
  after(:each) do
    FileUtils.rm_rf Dir["#{RADIANT_ROOT}/vendor/extensions/*"]
    FileUtils.rm_rf Dir["#{RADIANT_ROOT}/vendor/generators/*"]
  end
end

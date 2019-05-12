require File.dirname(__FILE__) + "/extension_generators_spec_helper"

describe "ExtensionMailerGenerator with normal options" do
  include GeneratorSpecHelperMethods
  it_should_behave_like "all generators"
  it_should_behave_like "all extension generators"
  
  before(:each) do
    FileUtils.cp_r File.join(BASE_ROOT, 'lib/generators/extension_mailer'), File.join(RADIANT_ROOT, 'vendor/generators')
    run_generator('extension_mailer', %w(example SignupNotifications thankyou))
  end
  
  it 'should generate the model file in the correct location' do
    'vendor/extensions/example'.should have_generated_model_for('SignupNotifications', 'ActionMailer::Base')
  end
  
  it 'should generate the view file in the correct location' do
    'vendor/extensions/example'.should have_generated_view_for('SignupNotifications', 'thankyou', 'erb')
  end
  
  after(:each) do
    extension_dir = File.join(RADIANT_ROOT, 'vendor/extensions/example')
    FileUtils.rm_rf Dir["#{extension_dir}/app/models/*"]
    FileUtils.rm_rf Dir["#{extension_dir}/app/views/*"]
    FileUtils.rm_rf Dir["#{RADIANT_ROOT}/vendor/generators/*"]
  end
end

describe "ExtensionMailerGenerator with test unit" do
  include GeneratorSpecHelperMethods
  it_should_behave_like "all generators"
  it_should_behave_like "all extension generators"
  
  before(:each) do
    FileUtils.cp_r File.join(BASE_ROOT, 'lib/generators/extension_mailer'), File.join(RADIANT_ROOT, 'vendor/generators')
    run_generator('extension_mailer', %w(example SignupNotifications thankyou --with-test-unit))
  end
  
  it 'should generate the model file in the correct location' do
    'vendor/extensions/example'.should have_generated_model_for('SignupNotifications', 'ActionMailer::Base')
  end
  
  it 'should generate the view file in the correct location' do
    'vendor/extensions/example'.should have_generated_view_for('SignupNotifications', 'thankyou', 'erb')
  end
  
  it 'should generate the unit test file in the correct location' do
    'vendor/extensions/example'.should have_generated_unit_test_for('SignupNotifications', 'ActionMailer::TestCase')
  end
  
  it 'should generate the fixture file in the correct location' do
    'vendor/extensions/example'.should have_generated_file('test/fixtures/signup_notifications/thankyou')
  end
  
  after(:each) do
    extension_dir = File.join(RADIANT_ROOT, 'vendor/extensions/example')
    FileUtils.rm_rf Dir["#{extension_dir}/app/models/*"]
    FileUtils.rm_rf Dir["#{extension_dir}/app/views/*"]
    FileUtils.rm_rf Dir["#{RADIANT_ROOT}/vendor/generators/*"]
    FileUtils.rm_rf Dir["#{extension_dir}/test/*"]
  end
end

require File.dirname(__FILE__) + "/extension_generators_spec_helper"

describe "ExtensionControllerGenerator with normal options" do
  it_should_behave_like AllGenerators
  it_should_behave_like AllExtensionGenerators
  
  before(:each) do
    cp_r File.join(BASE_ROOT, 'lib/generators/extension_controller'), File.join(RADIANT_ROOT, 'vendor/generators')
    run_generator('extension_controller', %w(example Events show new index))
  end
  
  it 'should generate the controller file in the correct location' do
    'vendor/extensions/example'.should have_generated_controller_for('Events') do |body|
      body.should have_methods(*%w(show new index))
    end
  end
  
  it 'should generate the controller spec file in the correct location' do
    'vendor/extensions/example'.should have_generated_controller_spec_for('Events')
  end
  
  it 'should generate the helper file in the correct location' do
    'vendor/extensions/example'.should have_generated_helper_for('Events')
  end
  
  it 'should generate the helper spec file in the correct location' do
    'vendor/extensions/example'.should have_generated_helper_spec_for('Events')
  end
  
  it 'should generate the view files in the correct location' do
    'vendor/extensions/example'.should have_generated_views_for('Events', %w(show new index))
  end
  
  it 'should generate the view spec file in the correct location' do
    'vendor/extensions/example'.should have_generated_view_specs_for('Events', *%w(show new index))
  end
  
  after(:each) do
    extension_dir = File.join(RADIANT_ROOT, 'vendor/extensions/example')
    rm_rf Dir["#{extension_dir}/app/controllers/*"]
    rm_rf Dir["#{extension_dir}/app/helpers/*"]
    rm_rf Dir["#{extension_dir}/app/views/*"]
    rm_rf Dir["#{extension_dir}/spec/controllers/*"]
    rm_rf Dir["#{extension_dir}/spec/helpers/*"]
    rm_rf Dir["#{extension_dir}/spec/views/*"]
    rm_rf Dir["#{RADIANT_ROOT}/vendor/generators/*"]
  end
end

describe "ExtensionControllerGenerator with test unit" do
  it_should_behave_like AllGenerators
  it_should_behave_like AllExtensionGenerators
  
  before(:each) do
    cp_r File.join(BASE_ROOT, 'lib/generators/extension_controller'), File.join(RADIANT_ROOT, 'vendor/generators')
    run_generator('extension_controller', %w(example Events show new index --with-test-unit))
  end
  
  it 'should generate the controller file in the correct location' do
    'vendor/extensions/example'.should have_generated_controller_for('Events') do |body|
      body.should have_methods(*%w(show new index))
    end
  end
  
  it 'should generate the controller spec file in the correct location' do
    'vendor/extensions/example'.should have_generated_functional_test_for('Events')
  end
  
  it 'should generate the helper file in the correct location' do
    'vendor/extensions/example'.should have_generated_helper_for('Events')
  end
  
  it 'should generate the view files in the correct location' do
    'vendor/extensions/example'.should have_generated_views_for('Events', %w(show new index))
  end
  
  after(:each) do
    extension_dir = File.join(RADIANT_ROOT, 'vendor/extensions/example')
    rm_rf Dir["#{extension_dir}/app/controllers/*"]
    rm_rf Dir["#{extension_dir}/app/helpers/*"]
    rm_rf Dir["#{extension_dir}/app/views/*"]
    rm_rf Dir["#{extension_dir}/test/*"]
    rm_rf Dir["#{RADIANT_ROOT}/vendor/generators/*"]
  end
end

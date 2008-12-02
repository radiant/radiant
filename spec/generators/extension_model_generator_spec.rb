require File.dirname(__FILE__) + "/extension_generators_spec_helper"

describe "ExtensionModelGenerator with normal options" do
  it_should_behave_like AllGenerators
  it_should_behave_like AllExtensionGenerators
  
  before(:each) do
    cp_r File.join(BASE_ROOT, 'lib/generators/extension_model'), File.join(RADIANT_ROOT, 'vendor/generators')
    run_generator('extension_model', %w(example Event))
  end
  
  it 'should generate the migration file in the correct location' do
    'vendor/extensions/example'.should have_generated_migration('CreateEvents')
  end
  
  it 'should generate the model file in the correct location' do
    'vendor/extensions/example'.should have_generated_model_for('Event')
  end
  
  it 'should generate the model spec file in the correct location' do
    'vendor/extensions/example'.should have_generated_model_spec_for('Event')
  end
  
  after(:each) do
    extension_dir = File.join(RADIANT_ROOT, 'vendor/extensions/example')
    rm_rf Dir["#{extension_dir}/db/migrate/*"]
    rm_rf Dir["#{extension_dir}/app/models/*"]
    rm_rf Dir["#{extension_dir}/spec/models/*"]
    rm_rf Dir["#{RADIANT_ROOT}/vendor/generators/*"]
  end
end

describe "ExtensionModelGenerator with test unit" do
  it_should_behave_like AllGenerators
  it_should_behave_like AllExtensionGenerators
  
  before(:each) do
    cp_r File.join(BASE_ROOT, 'lib/generators/extension_model'), File.join(RADIANT_ROOT, 'vendor/generators')
    run_generator('extension_model', %w(example Event --with-test-unit))
  end
  
  it 'should generate the migration file in the correct location' do
    'vendor/extensions/example'.should have_generated_migration('CreateEvents')
  end
  
  it 'should generate the model file in the correct location' do
    'vendor/extensions/example'.should have_generated_model_for('Event')
  end
  
  it 'should generate the unit test file in the correct location' do
    'vendor/extensions/example'.should have_generated_unit_test_for('Event')
  end
  
  after(:each) do
    extension_dir = File.join(RADIANT_ROOT, 'vendor/extensions/example')
    rm_rf Dir["#{extension_dir}/db/migrate/*"]
    rm_rf Dir["#{extension_dir}/app/models/*"]
    rm_rf Dir["#{extension_dir}/test/*"]
    rm_rf Dir["#{RADIANT_ROOT}/vendor/generators/*"]
  end
end

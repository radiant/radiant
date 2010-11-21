require File.dirname(__FILE__) + "/../spec_helper"

describe "Plugin Locators" do
  before :each do
    gem_path = File.join(RADIANT_ROOT, %w(test fixtures gems radiant-gem_ext-extension-0.0.0))
    spec = Gem::Specification.new
    spec.name = 'radiant-gem_ext-extension'
    spec.loaded_from = gem_path
    gem = Rails::GemDependency.new('radiant-gem_ext-extension')
    gem.specification = spec

    @configuration = Radiant::Configuration.new
    @configuration.gems = [gem]
    @initializer = Radiant::Initializer.new(@configuration)
  end

  describe Radiant::ExtensionLocator do
    it "should find plugins that are Radiant Extensions" do
      locator = Radiant::ExtensionLocator.new(@initializer)
      loaded_plugins = locator.plugins.select { |p| p.name == 'radiant-gem_ext-extension'}
      loaded_plugins.should_not be_empty
    end
  end

  describe Radiant::GemLocator do
    it "should skip plugins that are Radiant Extensions" do
      locator = Radiant::GemLocator.new(@initializer)
      loaded_plugins = locator.plugins.select { |p| p.name == 'radiant-gem_ext-extension'}
      loaded_plugins.should be_empty
    end
  end

  describe Radiant::Configuration do
    it "should have custom plugin locators" do
      locators = @configuration.plugin_locators
      locators.should include(Radiant::GemLocator)
      locators.should include(Radiant::ExtensionLocator)
      locators.should_not include(Rails::Plugin::GemLocator)
    end
  end
end
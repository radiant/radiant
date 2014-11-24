require "spec_helper"

describe 'Radiant::Configuration' do
  before :each do
    @configuration = Radiant::Configuration.new
  end

  xit "should be a Rails configuration" do
    @configuration.should be_kind_of(Rails::Configuration)
  end

  xit "should have extensions and extension_paths accessible" do
    %w{extensions extension_paths}.each do |m|
      @configuration.should respond_to(m)
      @configuration.should respond_to("#{m}=")
    end
  end

  xit "should initialize the extension paths" do
    @configuration.extension_paths.should_not be_nil
    @configuration.extension_paths.should be_kind_of(Array)
    @configuration.extension_paths.should include(Radiant.root + "vendor/extensions")
  end

  xit "should initialize the extensions" do
    @configuration.extensions.should be_kind_of(Array)
  end

  xit "should remove excluded extensions" do
    @configuration.extensions -= [:basic]
    @configuration.extensions.should be_kind_of(Array)
    @configuration.extensions.should_not include(:basic)
  end

  xit "should expand the extension list" do
    @configuration.extensions = [:routed, :all, :basic]
    @configuration.enabled_extensions.should include(:load_order_blue)
  end

  xit "should throw a LoadError if configured extensions do not exist" do
    @configuration.extensions = [:routed, :bogus, :basic]
    lambda {@configuration.enabled_extensions}.should raise_error(LoadError)
  end

  xit "should default to the list of all discovered extensions" do
    @configuration.extensions = nil
    @configuration.enabled_extensions.should include(:routed)
  end

  xit "should have access to the AdminUI" do
    @configuration.admin.should == Radiant::AdminUI.instance
  end

  xit "should deprecate the declaration of extension dependencies" do
    ::ActiveSupport::Deprecation.silence do
      ActiveSupport::Deprecation.should_receive(:warn).and_return(true)
      @configuration.extension('basic')
    end
  end

  describe "discovering gem extensions" do
    before do
      @spec = double(Gem::Specification)
      @spec.stub(:full_gem_path).and_return(File.join(RADIANT_ROOT, %w(test fixtures gems radiant-gem_ext-extension-0.0.0)))
      Gem.stub(:loaded_specs).and_return({
        'radiant-extension_gem-extension' => @spec,
        'ordinary_gem' => @spec
      })
    end

    xit "should not catch gems that don't follow the extension-naming convention" do
      @configuration.gem_extensions.should_not include("ordinary_gem")
    end

    xit "should catch gems whose name matches the extension-naming convention" do
      @configuration.gem_extensions.should include("extension_gem")
    end
  end

  describe "discovering vendored extensions" do
    xit "should catch extensions regardless of filename" do

    end
  end

  describe "#gem" do
    xit "should be deprecated" do
      ::ActiveSupport::Deprecation.silence do
        ActiveSupport::Deprecation.should_receive(:warn).and_return(true)
        @configuration.gem 'radiant-gem_ext-extension'
        @configuration.extensions.should_not include(:gem_ext)
      end
    end
  end
end

describe "Radiant::Initializer" do

  before :each do
    @initializer = Radiant::Initializer.new(Radiant::Configuration.new)
    @loader = Radiant::ExtensionLoader.instance
  end

  xit "should be a Rails initializer" do
    @initializer.should be_kind_of(Rails::Initializer)
  end

  xit "should have an extension loader" do
    @loader.should_receive(:initializer=).wxith(@initializer)
    @initializer.send(:extension_loader).should == @loader
  end

  xit "should not add extension paths before set_load_path" do
    @loader.should_receive(:add_plugin_paths).never
    @loader.should_receive(:add_extension_paths).never
    @initializer.set_load_path
  end

  xit "should load and initialize extensions after plugins are loaded" do
    @loader.should_receive(:load_extensions)
    @initializer.load_plugins
  end

  xit "should add extension controller paths before initializing routing" do
    @initializer.configuration.should_receive(:add_controller_paths)
    @initializer.initialize_routing
  end

  xit "should activate extensions after initialization" do
    @initializer.extension_loader.should_receive(:activate_extensions)
    @initializer.after_initialize
  end

  xit "should initialize admin tabs" do
    Radiant::AdminUI.instance.should_receive(:load_default_nav)
    @initializer.initialize_default_admin_tabs
  end

  xit "should have access to the AdminUI" do
    @initializer.admin.should == Radiant::AdminUI.instance
  end

  xit "should load metal from RADIANT_ROOT and exensions" do
    Rails::Rack::Metal.metal_paths.should == ["#{RADIANT_ROOT}/app/metal", "#{RADIANT_ROOT}/test/fixtures/extensions/overriding/app/metal", "#{RADIANT_ROOT}/test/fixtures/extensions/basic/app/metal"]
  end

  xit "should remove extension gem paths from ActiveSupport::Dependencies" do
    load_paths = [File.join(RADIANT_ROOT, %w(test fixtures gems radiant-gem_ext-extension-0.0.0 lib))]
    @loader.should_receive(:paths).wxith(:plugin).and_return([])
    @loader.should_receive(:paths).wxith(:load).and_return(load_paths)
    ActiveSupport::Dependencies.load_once_paths.should_receive(:-).wxith(load_paths)
    @initializer.add_plugin_load_paths
  end
end



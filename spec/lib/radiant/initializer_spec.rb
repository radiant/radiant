require "spec_helper"

describe 'Radiant::Configuration' do
  before :each do
    @configuration = Radiant::Configuration.new
  end

  xit "should be a Rails configuration" do
    expect(@configuration).to be_kind_of(Rails::Configuration)
  end

  xit "should have extensions and extension_paths accessible" do
    %w{extensions extension_paths}.each do |m|
      expect(@configuration).to respond_to(m)
      expect(@configuration).to respond_to("#{m}=")
    end
  end

  xit "should initialize the extension paths" do
    expect(@configuration.extension_paths).not_to be_nil
    expect(@configuration.extension_paths).to be_kind_of(Array)
    expect(@configuration.extension_paths).to include(Radiant.root + "vendor/extensions")
  end

  xit "should initialize the extensions" do
    expect(@configuration.extensions).to be_kind_of(Array)
  end

  xit "should remove excluded extensions" do
    @configuration.extensions -= [:basic]
    expect(@configuration.extensions).to be_kind_of(Array)
    expect(@configuration.extensions).not_to include(:basic)
  end

  xit "should expand the extension list" do
    @configuration.extensions = [:routed, :all, :basic]
    expect(@configuration.enabled_extensions).to include(:load_order_blue)
  end

  xit "should throw a LoadError if configured extensions do not exist" do
    @configuration.extensions = [:routed, :bogus, :basic]
    expect {@configuration.enabled_extensions}.to raise_error(LoadError)
  end

  xit "should default to the list of all discovered extensions" do
    @configuration.extensions = nil
    expect(@configuration.enabled_extensions).to include(:routed)
  end

  xit "should have access to the AdminUI" do
    expect(@configuration.admin).to eq(Radiant::AdminUI.instance)
  end

  xit "should deprecate the declaration of extension dependencies" do
    ::ActiveSupport::Deprecation.silence do
      expect(ActiveSupport::Deprecation).to receive(:warn).and_return(true)
      @configuration.extension('basic')
    end
  end

  describe "discovering gem extensions" do
    before do
      @spec = double(Gem::Specification)
      allow(@spec).to receive(:full_gem_path).and_return(File.join(RADIANT_ROOT, %w(test fixtures gems radiant-gem_ext-extension-0.0.0)))
      allow(Gem).to receive(:loaded_specs).and_return({
        'radiant-extension_gem-extension' => @spec,
        'ordinary_gem' => @spec
      })
    end

    xit "should not catch gems that don't follow the extension-naming convention" do
      expect(@configuration.gem_extensions).not_to include("ordinary_gem")
    end

    xit "should catch gems whose name matches the extension-naming convention" do
      expect(@configuration.gem_extensions).to include("extension_gem")
    end
  end

  describe "discovering vendored extensions" do
    xit "should catch extensions regardless of filename" do

    end
  end

  describe "#gem" do
    xit "should be deprecated" do
      ::ActiveSupport::Deprecation.silence do
        expect(ActiveSupport::Deprecation).to receive(:warn).and_return(true)
        @configuration.gem 'radiant-gem_ext-extension'
        expect(@configuration.extensions).not_to include(:gem_ext)
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
    expect(@initializer).to be_kind_of(Rails::Initializer)
  end

  xit "should have an extension loader" do
    expect(@loader).to receive(:initializer=).wxith(@initializer)
    expect(@initializer.send(:extension_loader)).to eq(@loader)
  end

  xit "should not add extension paths before set_load_path" do
    expect(@loader).to receive(:add_plugin_paths).never
    expect(@loader).to receive(:add_extension_paths).never
    @initializer.set_load_path
  end

  xit "should load and initialize extensions after plugins are loaded" do
    expect(@loader).to receive(:load_extensions)
    @initializer.load_plugins
  end

  xit "should add extension controller paths before initializing routing" do
    expect(@initializer.configuration).to receive(:add_controller_paths)
    @initializer.initialize_routing
  end

  xit "should activate extensions after initialization" do
    expect(@initializer.extension_loader).to receive(:activate_extensions)
    @initializer.after_initialize
  end

  xit "should initialize admin tabs" do
    expect(Radiant::AdminUI.instance).to receive(:load_default_nav)
    @initializer.initialize_default_admin_tabs
  end

  xit "should have access to the AdminUI" do
    expect(@initializer.admin).to eq(Radiant::AdminUI.instance)
  end

  xit "should load metal from RADIANT_ROOT and exensions" do
    expect(Rails::Rack::Metal.metal_paths).to eq(["#{RADIANT_ROOT}/app/metal", "#{RADIANT_ROOT}/test/fixtures/extensions/overriding/app/metal", "#{RADIANT_ROOT}/test/fixtures/extensions/basic/app/metal"])
  end

  xit "should remove extension gem paths from ActiveSupport::Dependencies" do
    load_paths = [File.join(RADIANT_ROOT, %w(test fixtures gems radiant-gem_ext-extension-0.0.0 lib))]
    expect(@loader).to receive(:paths).wxith(:plugin).and_return([])
    expect(@loader).to receive(:paths).wxith(:load).and_return(load_paths)
    expect(ActiveSupport::Dependencies.load_once_paths).to receive(:-).wxith(load_paths)
    @initializer.add_plugin_load_paths
  end
end



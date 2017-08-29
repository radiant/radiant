require "spec_helper"
require "radiant/extension_loader"

describe Radiant::ExtensionLoader do

  before :each do
    allow($LOAD_PATH).to receive(:unshift)
    @observer = double("observer")
    @configuration = double("configuration")
    allow(Radiant).to receive(:configuration).and_return(@configuration)
    @admin = double("admin_ui")
    @initializer = double("initializer")
    allow(@initializer).to receive(:configuration).and_return(@configuration)
    allow(@initializer).to receive(:admin).and_return(@admin)
    @loader = Radiant::ExtensionLoader.send(:new)
    @loader.initializer = @initializer
    @extensions = %w{basic overriding load_order_blue load_order_green load_order_red}
    @extension_paths = @extensions.each_with_object({}) do |ext, paths|
      paths[ext.to_sym] = File.expand_path("#{RADIANT_ROOT}/test/fixtures/extensions/#{ext}")
    end
    @extension_paths[:git_ext] = File.expand_path("#{RADIANT_ROOT}/test/fixtures/gems/radiant-gem_ext-extension-61e0ad14a3ae")
    allow(@loader).to receive(:known_extension_paths).and_return(@extension_paths)
    Radiant::AdminUI.instance.initialize_nav
  end

  it "should be a Simpleton" do
    expect(Radiant::ExtensionLoader.included_modules).to include(Simpleton)
  end

  it "should only load extensions specified in the configuration" do
    expect(@configuration).to receive(:enabled_extensions).at_least(:once).and_return([:basic])
    expect(@loader.enabled_extension_paths).to eq([File.expand_path("#{RADIANT_ROOT}/test/fixtures/extensions/basic")])
  end

  it "should select extensions in an explicit order from the configuration" do
    extensions = [:load_order_red, :load_order_blue, :load_order_green]
    extension_roots = extensions.map {|ext| File.expand_path("#{RADIANT_ROOT}/test/fixtures/extensions/#{ext}") }
    extension_roots.each { |ext| @loader.class.record_path(ext) }
    expect(@configuration).to receive(:enabled_extensions).at_least(:once).and_return(extensions)
    expect(@loader.enabled_extension_paths).to eq(extension_roots)
  end

  describe "loading extensions" do
    it "should load and initialize" do
      extensions = [:basic, :overriding]
      allow(@configuration).to receive(:enabled_extensions).and_return(extensions)
      @loader.load_extensions
      extensions.each do |ext|
        ext_class = Object.const_get(ext.to_s.camelize + "Extension")
        expect(ext_class).not_to be_nil
        expect(ext_class.root).not_to be_nil
      end
    end
  end

  describe "activating extensions" do
    it "should activate extensions" do
      extensions = [BasicExtension, OverridingExtension]
      @loader.extensions = extensions
      expect(@initializer).to receive(:initialize_views)
      @loader.activate_extensions
      expect(extensions.all?(&:active?)).to be true
    end

    it "should deactivate extensions" do
      extensions = [BasicExtension, OverridingExtension]
      @loader.extensions = extensions
      @loader.deactivate_extensions
      expect(extensions.any?(&:active?)).to be false
    end

    it "should (re)load Page subclasses on activation" do
      extensions = [BasicExtension, OverridingExtension]
      @loader.extensions = extensions
      expect(@initializer).to receive(:initialize_views)
      expect(Page).to receive(:load_subclasses)
      @loader.activate_extensions
    end
  end

  describe Radiant::ExtensionLoader::DependenciesObserver do
    before :each do
      @config = double("rails config")
      @observer = Radiant::ExtensionLoader::DependenciesObserver.new(@config)
    end

    it "should be a MethodObserver" do
      expect(@observer).to be_kind_of(MethodObserver)
    end

    it "should attach to the clear method" do
      expect(@observer).to respond_to(:before_clear)
      expect(@observer).to respond_to(:after_clear)
    end

    it "should deactivate extensions before clear" do
      expect(Radiant::ExtensionLoader).to receive(:deactivate_extensions)
      @observer.before_clear
    end

    it "should load and activate extensions after clear" do
      expect(Radiant::ExtensionLoader).to receive(:load_extensions)
      expect(Radiant::ExtensionLoader).to receive(:activate_extensions)
      @observer.after_clear
    end

  end
end

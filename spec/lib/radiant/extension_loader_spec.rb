require File.dirname(__FILE__) + "/../../spec_helper"

describe Radiant::ExtensionLoader do

  before :each do
    $LOAD_PATH.stub!(:unshift)
    @observer = mock("observer")
    @configuration = mock("configuration")
    Radiant.stub!(:configuration).and_return(@configuration)
    @admin = mock("admin_ui")
    @initializer = mock("initializer")
    @initializer.stub!(:configuration).and_return(@configuration)
    @initializer.stub!(:admin).and_return(@admin)
    @loader = Radiant::ExtensionLoader.send(:new)
    @loader.initializer = @initializer
    @extensions = %w{basic overriding load_order_blue load_order_green load_order_red}
    @extension_paths = @extensions.each_with_object({}) do |ext, paths|
      paths[ext.to_sym] = File.expand_path("#{RADIANT_ROOT}/test/fixtures/extensions/#{ext}")
    end
    @extension_paths[:git_ext] = File.expand_path("#{RADIANT_ROOT}/test/fixtures/gems/radiant-gem_ext-extension-61e0ad14a3ae")
    @loader.stub!(:known_extension_paths).and_return(@extension_paths)
    Radiant::AdminUI.instance.initialize_nav
  end

  it "should be a Simpleton" do
    Radiant::ExtensionLoader.included_modules.should include(Simpleton)
  end

  it "should only load extensions specified in the configuration" do
    @configuration.should_receive(:enabled_extensions).at_least(:once).and_return([:basic])
    @loader.enabled_extension_paths.should == [File.expand_path("#{RADIANT_ROOT}/test/fixtures/extensions/basic")]
  end

  it "should select extensions in an explicit order from the configuration" do
    extensions = [:load_order_red, :load_order_blue, :load_order_green]
    extension_roots = extensions.map {|ext| File.expand_path("#{RADIANT_ROOT}/test/fixtures/extensions/#{ext}") }
    extension_roots.each { |ext| @loader.class.record_path(ext) }
    @configuration.should_receive(:enabled_extensions).at_least(:once).and_return(extensions)
    @loader.enabled_extension_paths.should == extension_roots
  end

  describe "loading extensions" do
    it "should load and initialize" do
      extensions = [:basic, :overriding]
      @configuration.stub!(:enabled_extensions).and_return(extensions)
      @loader.load_extensions
      extensions.each do |ext|
        ext_class = Object.const_get(ext.to_s.camelize + "Extension")
        ext_class.should_not be_nil
        ext_class.root.should_not be_nil
      end
    end
  end
  
  describe "activating extensions" do
    it "should activate extensions" do
      extensions = [BasicExtension, OverridingExtension]
      @loader.extensions = extensions
      @initializer.should_receive(:initialize_views)
      @loader.activate_extensions
      extensions.all?(&:active?).should be_true
    end

    it "should deactivate extensions" do
      extensions = [BasicExtension, OverridingExtension]
      @loader.extensions = extensions
      @loader.deactivate_extensions
      extensions.any?(&:active?).should be_false
    end

    it "should (re)load Page subclasses on activation" do
      extensions = [BasicExtension, OverridingExtension]
      @loader.extensions = extensions
      @initializer.should_receive(:initialize_views)
      Page.should_receive(:load_subclasses)
      @loader.activate_extensions
    end
  end

  describe Radiant::ExtensionLoader::DependenciesObserver do
    before :each do
      @config = mock("rails config")
      @observer = Radiant::ExtensionLoader::DependenciesObserver.new(@config)
    end
  
    it "should be a MethodObserver" do
      @observer.should be_kind_of(MethodObserver)
    end
  
    it "should attach to the clear method" do
      @observer.should respond_to(:before_clear)
      @observer.should respond_to(:after_clear)
    end
  
    it "should deactivate extensions before clear" do
      Radiant::ExtensionLoader.should_receive(:deactivate_extensions)
      @observer.before_clear
    end
  
    it "should load and activate extensions after clear" do
      Radiant::ExtensionLoader.should_receive(:load_extensions)
      Radiant::ExtensionLoader.should_receive(:activate_extensions)
      @observer.after_clear
    end

  end
end

require File.dirname(__FILE__) + "/../../spec_helper"

describe Radiant::Configuration do
  before :each do
    @configuration = Radiant::Configuration.new
  end
  
  it "should be a Rails configuration" do
    @configuration.should be_kind_of(Rails::Configuration)
  end
  
  it "should have view_paths, extensions and extension_paths accessible" do
    %w{view_paths extensions extension_paths}.each do |m|
      @configuration.should respond_to(m)
      @configuration.should respond_to("#{m}=")
    end
  end
  
  it "should initialize the view paths to an array" do
    @configuration.view_paths.should_not be_nil
    @configuration.view_paths.should be_kind_of(Array)
  end
  
  it "should initialize the extension paths" do
    @configuration.extension_paths.should_not be_nil
    @configuration.extension_paths.should be_kind_of(Array)
    @configuration.extension_paths.should include("#{RADIANT_ROOT}/vendor/extensions") 
  end
  
  it "should initialize the extensions" do
    @configuration.extensions.should be_kind_of(Array)
    @configuration.extensions.should include(:archive, :textile_filter, :markdown_filter) 
  end
  
  it "should remove excluded extensions" do
    @configuration.extensions -= [:archive]
    @configuration.extensions.should be_kind_of(Array)
    @configuration.extensions.should_not include(:archive) 
  end
  
  it "should have extensions only found in extension paths" do
    @configuration.extension_paths = [RADIANT_ROOT + "/test/fixtures/extensions"]
    @configuration.extensions.should include(:basic, :overriding, :load_order_green) 
    @configuration.extensions.should_not include(:archive, :textile_filter, :markdown_filter) 
  end
  
  it "should have access to the AdminUI" do
    @configuration.admin.should == Radiant::AdminUI.instance
  end

  it "should initialize extension dependencies" do
    @configuration.extension_dependencies.should eql([])
  end

  it "should add extension dependencies" do
    @configuration.extension('basic')
    @configuration.extension_dependencies.should eql(['basic'])
  end

  it "should validate dependencies" do
    @configuration.extensions = [BasicExtension]
    @configuration.extension('basic')
    @configuration.check_extension_dependencies.should be_true
  end

  it "should report missing dependencies" do
    @configuration.extensions = [BasicExtension]
    @configuration.extension('does_not_exist')
    lambda {
      @configuration.check_extension_dependencies
    }.should raise_error(SystemExit)
  end

  describe "#all_available_extensions" do
    before do
      @spec = mock(Gem::Specification)
      @gem = mock(Rails::GemDependency, :specification => @spec)
      @configuration.gems = [@gem]
    end

    it "should not load gems that don't follow extension conventions" do
      @spec.stub!(:full_gem_path).and_return(File.join(RADIANT_ROOT, %w(test fixtures gems misnamed_ext-0.0.0)))
      available_extensions = @configuration.all_available_extensions.map(&:to_s)
      available_extensions.grep(/misnamed_ext/).should be_empty
    end

    it "should skip gems with invalid specifications" do
      @configuration.gems = [Rails::GemDependency.new('bogus_gem')]
      @configuration.all_available_extensions.should_not include(:bogus_gem)
    end

    it "should load gems matching radiant-*-extension" do
      @spec.stub!(:full_gem_path).and_return(File.join(RADIANT_ROOT, %w(test fixtures gems radiant-gem_ext-extension-0.0.0)))
      @configuration.all_available_extensions.should include(:gem_ext)
    end
  end
end

describe Radiant::Initializer do

  before :each do
    @initializer = Radiant::Initializer.new(Radiant::Configuration.new)
    @loader = Radiant::ExtensionLoader.instance
  end
  
  it "should be a Rails initializer" do
    @initializer.should be_kind_of(Rails::Initializer)
  end

  it "should have an extension loader" do
    @loader.should_receive(:initializer=).with(@initializer)
    @initializer.send(:extension_loader).should == @loader
  end

  it "should not add extension paths before set_load_path" do
    @loader.should_receive(:add_plugin_paths).never
    @loader.should_receive(:add_extension_paths).never
    @initializer.set_load_path
  end
  
  it "should load and initialize extensions after plugins are loaded" do
    @loader.should_receive(:load_extensions)
    @initializer.load_plugins
  end
  
  it "should add extension controller paths before initializing routing" do
    @loader.should_receive(:add_controller_paths)
    @initializer.initialize_routing
  end
  
  it "should activate extensions after initialization" do
    @initializer.extension_loader.should_receive(:activate_extensions)
    @initializer.after_initialize
  end
  
  it "should initialize admin tabs" do
    Radiant::AdminUI.instance.should_receive(:load_default_nav)
    @initializer.initialize_default_admin_tabs
  end
  
  it "should have access to the AdminUI" do
    @initializer.admin.should == Radiant::AdminUI.instance
  end

  it "should load metal from RADIANT_ROOT and exensions" do
    Rails::Rack::Metal.metal_paths.should == ["#{RADIANT_ROOT}/app/metal", "#{RADIANT_ROOT}/test/fixtures/extensions/overriding/app/metal", "#{RADIANT_ROOT}/test/fixtures/extensions/basic/app/metal"]
  end

  it "should check dependent extensions" do
    @initializer.configuration.frameworks = [] # ActionMailer not loaded at this point
    @initializer.configuration.should_receive(:check_extension_dependencies)
    @initializer.after_initialize
  end

  it "should remove extension gem paths from ActiveSupport::Dependencies" do
    load_paths = [File.join(RADIANT_ROOT, %w(test fixtures gems radiant-gem_ext-extension-0.0.0 lib))]
    @loader.stub!(:extension_load_paths).and_return(load_paths)
    ActiveSupport::Dependencies.load_once_paths.should_receive(:-).with(load_paths)
    @initializer.add_plugin_load_paths
  end
end

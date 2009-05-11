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
    @initializer.initialize_default_admin_tabs
    Radiant::AdminUI.instance.tabs.size.should == 3
  end
  
  it "should have access to the AdminUI" do
    @initializer.admin.should == Radiant::AdminUI.instance
  end

  it "should check dependent extensions" do
    @initializer.configuration.should_receive(:check_extension_dependencies)
    @initializer.after_initialize
  end

end

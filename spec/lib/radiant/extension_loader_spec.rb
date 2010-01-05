require File.dirname(__FILE__) + "/../../spec_helper"

describe Radiant::ExtensionLoader do

  before :each do
    $LOAD_PATH.stub!(:unshift)
    @observer = mock("observer")
    @configuration = mock("configuration")
    @admin = mock("admin_ui")
    @initializer = mock("initializer")
    @initializer.stub!(:configuration).and_return(@configuration)
    @initializer.stub!(:admin).and_return(@admin)
    @instance = Radiant::ExtensionLoader.send(:new)
    @instance.initializer = @initializer

    @extensions = %w{basic overriding load_order_blue load_order_green load_order_red}
    @extension_paths = @extensions.map do |ext|
      File.expand_path("#{RADIANT_ROOT}/test/fixtures/extensions/#{ext}")
    end
    Radiant::AdminUI.tabs.clear
  end

  it "should be a Simpleton" do
    Radiant::ExtensionLoader.included_modules.should include(Simpleton)
  end

  it "should have the initializer's configuration" do
    @initializer.should_receive(:configuration).and_return(@configuration)
    @instance.configuration.should == @configuration
  end

  it "should only load extensions specified in the configuration" do
    @configuration.should_receive(:extensions).at_least(:once).and_return([:basic])
    @instance.stub!(:all_extension_roots).and_return(@extension_paths)
    @instance.send(:select_extension_roots).should == [File.expand_path("#{RADIANT_ROOT}/test/fixtures/extensions/basic")]
  end

  it "should load gem extensions with paths matching radiant-*-extension" do
    gem_path = File.join RADIANT_ROOT, %w(test fixtures gems radiant-gem_ext-extension-0.0.0)
    @configuration.should_receive(:extensions).at_least(:once).and_return([:gem_ext])
    @instance.stub!(:all_extension_roots).and_return([File.expand_path gem_path])
    @instance.send(:select_extension_roots).should == [gem_path]
  end

  it "should select extensions in an explicit order from the configuration" do
    extensions = [:load_order_red, :load_order_blue, :load_order_green]
    extension_roots = extensions.map {|ext| File.expand_path("#{RADIANT_ROOT}/test/fixtures/extensions/#{ext}") }
    @instance.stub!(:all_extension_roots).and_return(@extension_paths)
    @configuration.should_receive(:extensions).at_least(:once).and_return(extensions)
    @instance.send(:select_extension_roots).should == extension_roots
  end

  it "should insert all unspecified extensions into the paths at position of :all in configuration" do
    extensions = [:load_order_red, :all, :load_order_green]
    extension_roots = @extension_paths[0..-2].unshift(@extension_paths[-1])
    @instance.stub!(:all_extension_roots).and_return(@extension_paths)
    @configuration.should_receive(:extensions).at_least(:once).and_return(extensions)
    @instance.send(:select_extension_roots).should == extension_roots
  end

  it "should raise an error when an extension named in the configuration cannot be found" do
    extensions = [:foobar]
    @instance.stub!(:all_extension_roots).and_return(@extension_paths)
    @configuration.should_receive(:extensions).at_least(:once).and_return(extensions)
    lambda { @instance.send(:select_extension_roots) }.should raise_error(LoadError)
  end

  it "should skip invalid gems" do
    @configuration.stub!(:extension_paths).and_return([])
    @configuration.stub!(:gems).and_return([Rails::GemDependency.new('bogus_gem')])
    @instance.send(:all_extension_roots).should eql([])
  end

  it "should determine load paths from an extension path" do
    @instance.send(:load_paths_for, "#{RADIANT_ROOT}/vendor/extensions/archive").should == %W{
        #{RADIANT_ROOT}/vendor/extensions/archive/lib
        #{RADIANT_ROOT}/vendor/extensions/archive/app/models
        #{RADIANT_ROOT}/vendor/extensions/archive/test/helpers
        #{RADIANT_ROOT}/vendor/extensions/archive}
  end

  it "should have load paths" do
    @instance.stub!(:load_extension_roots).and_return(@extension_paths)
    @instance.should respond_to(:extension_load_paths)
    @instance.extension_load_paths.should be_instance_of(Array)
    @instance.extension_load_paths.all? {|f| File.directory?(f) }.should be_true
  end

  it "should have plugin paths" do
    @instance.stub!(:load_extension_roots).and_return(@extension_paths)
    @instance.should respond_to(:plugin_paths)
    @instance.plugin_paths.should be_instance_of(Array)
    @instance.plugin_paths.all? {|f| File.directory?(f) }.should be_true
  end

  it "should add extension paths to the configuration" do
    load_paths = []
    @instance.should_receive(:extension_load_paths).and_return(@extension_paths)
    @configuration.should_receive(:load_paths).at_least(:once).and_return(load_paths)
    @instance.add_extension_paths
    load_paths.should == @extension_paths
  end

  it "should add plugin paths to the configuration" do
    plugin_paths = []
    @instance.should_receive(:plugin_paths).and_return([@extension_paths.first + "/vendor/plugins"])
    @configuration.should_receive(:plugin_paths).and_return(plugin_paths)
    @instance.add_plugin_paths
    plugin_paths.should == [@extension_paths.first + "/vendor/plugins"]
  end

  it "should add plugin paths in the same order as the extension load order" do
    plugin_paths = []
    ext_plugin_paths = @extension_paths[0..1].map {|e| e + "/vendor/plugins" }
    @instance.should_receive(:load_extension_roots).and_return(@extension_paths)
    @configuration.should_receive(:plugin_paths).and_return(plugin_paths)
    @instance.add_plugin_paths
    plugin_paths.should == ext_plugin_paths
  end

  it "should have controller paths" do
    @instance.should respond_to(:controller_paths)
    @instance.controller_paths.should be_instance_of(Array)
    @instance.controller_paths.all? {|f| File.directory?(f) }.should be_true
  end

  it "should add controller paths to the configuration" do
    controller_paths = []
    @instance.stub!(:extensions).and_return([BasicExtension])
    @configuration.should_receive(:controller_paths).and_return(controller_paths)
    @instance.add_controller_paths
    controller_paths.should include(BasicExtension.root + "/app/controllers")
  end

  it "should have view paths" do
    @instance.should respond_to(:view_paths)
    @instance.view_paths.should be_instance_of(Array)
    @instance.view_paths.all? {|f| File.directory?(f) }.should be_true
  end

  it "should have metal paths" do
    @instance.stub!(:load_extension_roots).and_return(@extension_paths)
    @instance.should respond_to(:metal_paths)
    @instance.metal_paths.should be_instance_of(Array)
    @instance.metal_paths.all? {|f| File.directory?(f) }.should be_true
  end

  it "should return the view paths in inverse order to the loaded" do
    extensions = [BasicExtension, OverridingExtension]
    @instance.extensions = extensions
    @instance.view_paths.should == [
       "#{RADIANT_ROOT}/test/fixtures/extensions/overriding/app/views",
       "#{RADIANT_ROOT}/test/fixtures/extensions/basic/app/views"
      ]
  end

  it "should return the metal paths in inverse order to the loaded" do
    @instance.should_receive(:load_extension_roots).and_return(@extension_paths)
    extensions = [BasicExtension, OverridingExtension]
    @instance.extensions = extensions
    @instance.metal_paths.should == [
       "#{RADIANT_ROOT}/test/fixtures/extensions/overriding/app/metal",
       "#{RADIANT_ROOT}/test/fixtures/extensions/basic/app/metal"
      ]
  end
  
  it "should load and initialize extensions when discovering" do
    @instance.should_receive(:load_extension_roots).and_return(@extension_paths)
    @instance.load_extensions
    @extensions.each do |ext|
      ext_class = Object.const_get(ext.gsub(/^\d+_/, '').camelize + "Extension")
      ext_class.should_not be_nil
      ext_class.root.should_not be_nil
    end
  end

  it "should load extensions from gem paths" do
    # Mock gem loading
    gem_path = File.expand_path(File.join(RADIANT_ROOT, %w(test fixtures gems radiant-gem_ext-extension-0.0.0)))
    $: << gem_path
    require 'gem_ext_extension'
    @instance.should_receive(:load_extension_roots).and_return([gem_path])

    @instance.load_extensions.should include(GemExtExtension)
  end

  it "should deactivate extensions" do
    extensions = [BasicExtension, OverridingExtension]
    @instance.extensions = extensions
    @instance.deactivate_extensions
    extensions.any?(&:active?).should be_false
  end

  it "should activate extensions" do
    @initializer.should_receive(:initialize_default_admin_tabs)
    @initializer.should_receive(:initialize_framework_views)
    @admin.should_receive(:load_default_regions)
    extensions = [BasicExtension, OverridingExtension]
    @instance.extensions = extensions
    @instance.activate_extensions
    extensions.all?(&:active?).should be_true
  end

  it "should (re)load Page subclasses activation" do
    @initializer.should_receive(:initialize_default_admin_tabs)
    @initializer.should_receive(:initialize_framework_views)
    @admin.should_receive(:load_default_regions)
    extensions = [BasicExtension, OverridingExtension]
    @instance.extensions = extensions
    Page.should_receive(:load_subclasses)
    @instance.activate_extensions
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

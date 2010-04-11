require File.dirname(__FILE__) + "/../../spec_helper"

describe Radiant::Extension do

  it "should be a Simpleton" do
    Radiant::Extension.included_modules.should include(Simpleton)
    Radiant::Extension.should respond_to(:instance)
  end
  
  it "should annotate version, description, url, root and extension_name" do
    Radiant::Extension.included_modules.should include(Annotatable)
    %w{version description url root extension_name}.each do |attribute|
      Radiant::Extension.should respond_to(attribute)
    end
  end
  
  it "should have access to the Radiant::AdminUI instance" do
    BasicExtension.instance.should respond_to(:admin)
    BasicExtension.admin.should == Radiant::AdminUI.instance
  end
  
  it "should have a migrator" do
    BasicExtension.instance.should respond_to(:migrator)
    BasicExtension.migrator.superclass.should == Radiant::ExtensionMigrator
  end
  
  it "should have a migrations path" do
    BasicExtension.migrations_path.should == "#{RADIANT_ROOT}/test/fixtures/extensions/basic/db/migrate"
  end
  
  describe BasicExtension do
    its(:routing_file) { should match '/extensions/basic/config/routes.rb' }
  end
  
  context "when the routing_file exists" do
    subject { RoutedExtension }
    it { should be_routed }
  end
  context "when the routing_file does not exist" do
    subject { BasicExtension }
    it { should_not be_routed }
  end
  
  it "should set the extension_name in subclasses" do
    Kernel.module_eval { class SuperExtension < Radiant::Extension; end }
    SuperExtension.extension_name.should == "Super"
  end
  
  it "should store route definitions defined in a block" do
    Radiant::Extension.should respond_to(:define_routes)
    my_block = proc {|map| map.stuff "stuff", :controller => "admin/pages" }
    Radiant::Extension.define_routes(&my_block)
    Radiant::Extension.route_definitions.should be_instance_of(Array)
    Radiant::Extension.route_definitions.first.should == my_block
  end

  it "should expose configuration object" do
    SuperExtension.extension_config do |config|
      config.should eql(Rails.configuration)
    end
  end

  it "should allow the manipulation of tabs" do
    BasicExtension.admin.nav['Design'].length.should == 2
    BasicExtension.class_eval {
      tab 'Design' do
        add_item "Pages", "/admin/pages"
      end
    }
    BasicExtension.admin.nav['Design'].length.should == 3
  end
  
  it "should allow the addition of tabs" do
    start_length = BasicExtension.admin.nav.length
    BasicExtension.class_eval {
      tab 'Additional'
    }
    BasicExtension.admin.nav.length.should == start_length + 1
  end

  describe ".extension_enabled?" do
    it "should be false if extension does not exist" do
      BasicExtension.extension_enabled?(:bogus).should be_false
    end

    it "should be false if extension is inactive" do
      OverridingExtension.active = false
      BasicExtension.extension_enabled?(:overriding).should be_false
    end

    it "should be false if extension is not migrated" do
      UpgradingExtension.migrator.new(:up, UpgradingExtension.migrations_path).pending_migrations.should_not be_empty # sanity check
      BasicExtension.extension_enabled?(:upgrading).should be_false
    end

    it "should be true if extension is defined and migrated" do
      ActiveRecord::Migration.suppress_messages do
        UpgradingExtension.migrator.migrate
      end
      BasicExtension.extension_enabled?(:upgrading).should be_true
    end
  end
end

describe Radiant::Extension, "when inactive" do

  before :each do
    BasicExtension.deactivate
    Radiant::AdminUI.tabs.clear
  end

  it "should become active when activated" do
    BasicExtension.activate
    BasicExtension.active?.should == true
  end
  
end

describe Radiant::Extension, "when active" do

  it "should become deactive when deactivated" do
    BasicExtension.deactivate
    BasicExtension.active?.should == false
  end

  # This example needs revisiting and more detail
  it "should have loaded plugins stored in vendor/plugins" do
    defined?(Multiple).should_not be_nil
    defined?(NormalPlugin).should_not be_nil
  end
  
end

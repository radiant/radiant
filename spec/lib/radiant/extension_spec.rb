require "spec_helper"
extensions_path = File.expand_path('../../../fixtures/extensions', __FILE__)
$: << extensions_path
require "basic/basic_extension"

describe Radiant::Extension do

  it "should be a Simpleton" do
    expect(Radiant::Extension.included_modules).to include(Simpleton)
    expect(Radiant::Extension).to respond_to(:instance)
  end

  it "should annotate version, description, url, path and extension_name" do
    expect(Radiant::Extension.included_modules).to include(Annotatable)
    %w{version description url path extension_name}.each do |attribute|
      expect(Radiant::Extension).to respond_to(attribute)
    end
  end

  it "should have access to the Radiant::AdminUI instance" do
    expect(BasicExtension.instance).to respond_to(:admin)
    expect(BasicExtension.admin).to eq(Radiant::AdminUI.instance)
  end

  it "should have a migrator" do
    expect(BasicExtension.instance).to respond_to(:migrator)
    expect(BasicExtension.migrator.superclass).to eq(Radiant::ExtensionMigrator)
  end

  it "should have a migrations path" do
    expect(BasicExtension.migrations_path).to eq("#{RADIANT_ROOT}/test/fixtures/extensions/basic/db/migrate")
  end

  describe 'BasicExtension' do
    describe '#routing_file' do
      subject { super().routing_file }
      it { is_expected.to match '/extensions/basic/config/routes.rb' }
    end
  end

  context "when the routing_file exists" do
    subject { RoutedExtension }
    it { is_expected.to be_routed }
  end
  context "when the routing_file does not exist" do
    subject { UnroutedExtension }
    it { is_expected.not_to be_routed }
  end

  it "should set the extension_name in subclasses" do
    Kernel.module_eval { class SuperExtension < Radiant::Extension; end }
    expect(SuperExtension.extension_name).to eq("Super")
  end

  it "should expose configuration object" do
    SuperExtension.extension_config do |config|
      expect(config).to eql(Rails.configuration)
    end
  end

  it "should allow the addition of items" do
    start_length = BasicExtension.admin.nav['Design'].length
    BasicExtension.class_eval {
      tab 'Design' do
        add_item "Pages", "/admin/pages"
      end
    }
    expect(BasicExtension.admin.nav['Design'].length).to eq(start_length + 1)
  end

  it "should allow the ordering of nav tabs after other tabs" do
    nav = BasicExtension.admin.nav
    BasicExtension.class_eval {
      tab "Assets", before: "Design"
    }
    assets = nav["Assets"]
    content = nav["content"]
    expect(nav.index(assets)).to eq(nav.index(content) + 1)
  end

  it "should allow the ordering of nav tabs before other tabs" do
    nav = BasicExtension.admin.nav
    BasicExtension.class_eval {
      tab "Assets", before: "Design"
    }
    assets = nav["Assets"]
    design = nav["Design"]
    expect(nav.index(assets)).to eq(nav.index(design) - 1)
  end

  it "should allow the addition of tabs" do
    start_length = BasicExtension.admin.nav.length
    BasicExtension.class_eval {
      tab 'Additional'
    }
    expect(BasicExtension.admin.nav.length).to eq(start_length + 1)
  end

  describe ".extension_enabled?" do
    it "should be false if extension does not exist" do
      expect(BasicExtension.extension_enabled?(:bogus)).to be false
    end

    it "should be false if extension is inactive" do
      OverridingExtension.active = false
      expect(BasicExtension.extension_enabled?(:overriding)).to be false
    end

    it "should be false if extension is not migrated" do
      expect(UpgradingExtension.migrator.new(:up, UpgradingExtension.migrations_path).pending_migrations).not_to be_empty # sanity check
      expect(BasicExtension.extension_enabled?(:upgrading)).to be false
    end

    it "should be true if extension is defined and migrated" do
      ActiveRecord::Migration.suppress_messages do
        UpgradingExtension.migrator.migrate
      end
      expect(BasicExtension.extension_enabled?(:upgrading)).to be true
    end
  end
end

describe Radiant::Extension, "when inactive" do

  before :each do
    BasicExtension.deactivate
    Radiant::AdminUI.instance.initialize_nav
  end

  it "should become active when activated" do
    BasicExtension.activate
    expect(BasicExtension.active?).to eq(true)
  end

end

describe Radiant::Extension, "when active" do

  it "should become deactive when deactivated" do
    BasicExtension.deactivate
    expect(BasicExtension.active?).to eq(false)
  end

  # This example needs revisiting and more detail
  it "should have loaded plugins stored in vendor/plugins" do
    expect(defined?(Multiple)).not_to be_nil
    expect(defined?(NormalPlugin)).not_to be_nil
  end

end

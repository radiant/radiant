require 'spec_helper'
require 'radiant/extension_migrator'

describe Radiant::ExtensionMigrator do

  class Person < ActiveRecord::Base; end
  class Place < ActiveRecord::Base; end

  before :each do
    ActiveRecord::Base.connection.delete("DELETE FROM schema_migrations WHERE version LIKE 'Basic-%' OR version LIKE 'Upgrading-%' OR version LIKE 'Replacing-%'")
    ActiveRecord::Base.connection.delete("DELETE FROM extension_meta WHERE name = 'Upgrading'")
  end

  it 'should migrate new style migrations successfully' do
    ActiveRecord::Migration.suppress_messages do
      BasicExtension.migrator.migrate
    end
    expect(BasicExtension.migrator.get_all_versions).to eq([200812131420,200812131421])
    expect { Person.all }.not_to raise_error
    expect { Place.all }.not_to raise_error
    ActiveRecord::Migration.suppress_messages do
      BasicExtension.migrator.migrate(0)
    end
    expect(BasicExtension.migrator.get_all_versions).to eq([])
  end

  it 'should migrate extensions with unusual names' do
    ActiveRecord::Migration.suppress_messages do
      SpecialCharactersExtension.migrator.migrate
    end
    expect(SpecialCharactersExtension.migrator.get_all_versions).to eq([1])
    expect { Person.all }.not_to raise_error
    ActiveRecord::Migration.suppress_messages do
      SpecialCharactersExtension.migrator.migrate(0)
    end
    expect(SpecialCharactersExtension.migrator.get_all_versions).to eq([])
  end

  it "should record existing extension migrations in the schema_migrations table" do
    ActiveRecord::Base.connection.insert("INSERT INTO extension_meta (name, schema_version) VALUES ('Upgrading', 2)")
    ActiveRecord::Migration.suppress_messages do
      UpgradingExtension.migrator.migrate(3)
    end
    expect(UpgradingExtension.migrator.get_all_versions).to eq([1,2,3])
    expect(ActiveRecord::Base.connection.select_values("SELECT * FROM extension_meta WHERE name = 'Upgrading'")).to be_empty
  end

  it "should obey migrate_from instructions" do
    ActiveRecord::Migration.suppress_messages do
      BasicExtension.migrator.migrate
      expect{ ReplacingExtension.migrator.migrate }.not_to raise_error
    end
    expect(ReplacingExtension.migrator.get_all_versions).to eq([200812131420,201106021232])
  end

  describe '#migrate_extensions' do
    it 'should migrate in the order of the specified extension load order' do
      expect(BasicExtension.migrator).to receive(:migrate).once
      expect(UpgradingExtension.migrator).to receive(:migrate).once
      allow(Rails.configuration).to receive(:enabled_extensions).and_return([:basic, :upgrading])
      Radiant::ExtensionMigrator.migrate_extensions
    end
  end
end

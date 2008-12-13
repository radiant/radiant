require File.dirname(__FILE__) + '/../../spec_helper'

describe Radiant::ExtensionMigrator do
  
  class Person < ActiveRecord::Base; end
  class Place < ActiveRecord::Base; end

  before :each do
    ActiveRecord::Base.connection.delete("DELETE FROM schema_migrations WHERE version LIKE 'Basic-%' OR version LIKE 'Upgrading-%'")
    ActiveRecord::Base.connection.delete("DELETE FROM extension_meta WHERE name = 'Upgrading'")
  end
  
  it 'should migrate new style migrations successfully' do
    ActiveRecord::Migration.suppress_messages do
      BasicExtension.migrator.migrate
    end
    BasicExtension.migrator.get_all_versions.should == [200812131420,200812131421]
    lambda { Person.find(:all) }.should_not raise_error
    lambda { Place.find(:all) }.should_not raise_error
    ActiveRecord::Migration.suppress_messages do
      BasicExtension.migrator.migrate(0)
    end
    BasicExtension.migrator.get_all_versions.should == []
  end
  
  it "should record existing extension migrations in the schema_migrations table" do
    ActiveRecord::Base.connection.insert("INSERT INTO extension_meta (name, schema_version) VALUES ('Upgrading', 2)")
    ActiveRecord::Migration.suppress_messages do
      UpgradingExtension.migrator.migrate(3)
    end
    UpgradingExtension.migrator.get_all_versions.should == [1,2,3]
    ActiveRecord::Base.connection.select_values("SELECT * FROM extension_meta WHERE name = 'Upgrading'").should be_empty
  end
end

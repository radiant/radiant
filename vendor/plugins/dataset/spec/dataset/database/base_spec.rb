require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe Dataset::Database::Base do
  before do
    @database = Dataset::Database::Base.new
  end
  
  it 'should clear the tables of all AR classes' do
    Place.create!
    Thing.create!
    @database.clear
    Place.count.should be(0)
    Thing.count.should be(0)
  end
  
  it 'should not clear the "schema_migrations" table' do
    ActiveRecord::Base.connection.insert("INSERT INTO #{ActiveRecord::Migrator.schema_migrations_table_name} (version) VALUES ('testing123')")
    @database.clear
    ActiveRecord::Base.connection.select_one("SELECT version FROM #{ActiveRecord::Migrator.schema_migrations_table_name} WHERE version = 'testing123'").should_not be_blank
  end
end
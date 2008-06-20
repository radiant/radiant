require File.dirname(__FILE__) + '/../../spec_helper'

describe Radiant::ExtensionMigrator do
  
  class Person < ActiveRecord::Base; end
  class Place < ActiveRecord::Base; end
  
  it 'should migrate successfully' do
    ActiveRecord::Migration.suppress_messages do
      BasicExtension.migrator.migrate
    end
    BasicExtension.migrator.current_version.should == 2
    lambda { Person.find(:all) }.should_not raise_error
    lambda { Place.find(:all) }.should_not raise_error
  end
  
end

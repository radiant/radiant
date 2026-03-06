require "test_helper"

class Radiant::ExtensionMigratorTest < ActiveSupport::TestCase
  test "ExtensionMigrator class exists" do
    assert defined?(Radiant::ExtensionMigrator)
  end

  test "ExtensionMigrator inherits from ActiveRecord::Migrator" do
    assert Radiant::ExtensionMigrator < ActiveRecord::Migrator
  end

  test "has extension class accessor" do
    assert Radiant::ExtensionMigrator.respond_to?(:extension)
    assert Radiant::ExtensionMigrator.respond_to?(:extension=)
  end
end

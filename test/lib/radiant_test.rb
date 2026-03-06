require "test_helper"

class RadiantTest < ActiveSupport::TestCase
  test "has loaded_via_gem? method" do
    assert_respond_to Radiant, :loaded_via_gem?
  end

  test "loaded_via_gem? returns a boolean" do
    assert_includes [true, false], Radiant.loaded_via_gem?
  end

  test "Version module exists" do
    assert defined?(Radiant::Version), "Radiant::Version should be defined"
  end

  test "Version has Major constant" do
    assert defined?(Radiant::Version::Major)
    assert_kind_of String, Radiant::Version::Major
  end

  test "Version has Minor constant" do
    assert defined?(Radiant::Version::Minor)
    assert_kind_of String, Radiant::Version::Minor
  end

  test "Version has Tiny constant" do
    assert defined?(Radiant::Version::Tiny)
    assert_kind_of String, Radiant::Version::Tiny
  end

  test "Version.to_s returns a string" do
    version_string = Radiant::Version.to_s
    assert_kind_of String, version_string
    assert_match(/\A\d+\.\d+\.\d+/, version_string)
  end

  test "Version.to_str is aliased to to_s" do
    assert_equal Radiant::Version.to_s, Radiant::Version.to_str
  end

  test "RADIANT_ROOT is defined" do
    assert defined?(RADIANT_ROOT), "RADIANT_ROOT should be defined"
    assert_kind_of String, RADIANT_ROOT
  end
end

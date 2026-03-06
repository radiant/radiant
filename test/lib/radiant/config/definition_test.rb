require "test_helper"

class Radiant::Config::DefinitionTest < ActiveSupport::TestCase
  test "basic definition with default value" do
    definition = Radiant::Config::Definition.new(default: "something")
    assert_equal "something", definition.default
    assert_not definition.empty?
  end

  test "empty definition has empty flag" do
    definition = Radiant::Config::Definition.new(empty: true)
    assert definition.empty?
  end

  test "boolean definition type" do
    definition = Radiant::Config::Definition.new(type: :boolean)
    assert definition.boolean?
    assert_not definition.integer?
  end

  test "integer definition type" do
    definition = Radiant::Config::Definition.new(type: :integer)
    assert definition.integer?
    assert_not definition.boolean?
  end

  test "validation with validate_with block" do
    validator = ->(setting) { setting.errors.add(:value, "custom error") if setting.value == "bad" }
    definition = Radiant::Config::Definition.new(validate_with: validator)
    assert_equal validator, definition.validate_with
  end

  test "selection from array" do
    definition = Radiant::Config::Definition.new(select_from: %w[one two three])
    assert definition.selector?
    selections = definition.selection
    # By default allow_blank is true, so blank option is prepended
    assert_includes selections, ["one", "one"]
    assert_includes selections, ["two", "two"]
    assert_includes selections, ["three", "three"]
  end

  test "selection from hash" do
    definition = Radiant::Config::Definition.new(select_from: { "Label A" => "a", "Label B" => "b" })
    assert definition.selector?
    selections = definition.selection
    assert_includes selections, ["Label A", "a"]
    assert_includes selections, ["Label B", "b"]
  end

  test "selection from lambda" do
    definition = Radiant::Config::Definition.new(select_from: -> { %w[x y z] })
    assert definition.selector?
    selections = definition.selection
    assert_includes selections, ["x", "x"]
    assert_includes selections, ["y", "y"]
    assert_includes selections, ["z", "z"]
  end

  test "selectable checks value against selection" do
    definition = Radiant::Config::Definition.new(select_from: %w[one two three])
    assert definition.selectable?("one")
    assert definition.selectable?("ONE")
    assert_not definition.selectable?("four")
  end

  test "protected settings with allow_change false" do
    definition = Radiant::Config::Definition.new(allow_change: false)
    assert_not definition.settable?
  end

  test "settable by default" do
    definition = Radiant::Config::Definition.new
    assert definition.settable?
  end

  test "required settings with allow_blank false" do
    definition = Radiant::Config::Definition.new(allow_blank: false)
    assert_not definition.allow_blank?
  end

  test "allow_blank is true by default" do
    definition = Radiant::Config::Definition.new
    assert definition.allow_blank?
  end

  test "visible by default" do
    definition = Radiant::Config::Definition.new
    assert definition.visible?
    assert_not definition.hidden?
  end

  test "hidden when allow_display is false" do
    definition = Radiant::Config::Definition.new(allow_display: false)
    assert_not definition.visible?
    assert definition.hidden?
  end

  test "selection with allow_blank prepends empty option" do
    definition = Radiant::Config::Definition.new(select_from: %w[a b], allow_blank: nil)
    selections = definition.selection
    assert_equal ["", ""], selections.first
  end
end

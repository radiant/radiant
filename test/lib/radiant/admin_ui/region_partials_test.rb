require "test_helper"
require "ostruct"

class Radiant::AdminUI::RegionPartialsTest < ActiveSupport::TestCase
  setup do
    @template = OpenStruct.new
    def @template.capture(&block)
      @captured_block = block
      block.call
    end
    @partials = Radiant::AdminUI::RegionPartials.new(@template)
  end

  test "returns error string for missing partial" do
    result = @partials["nonexistent"]
    assert_match(/nonexistent/, result)
    assert_match(/not found/, result)
  end

  test "bracket accessor returns string for missing key" do
    value = @partials["some_partial"]
    assert_kind_of String, value
  end

  test "bracket accessor works with symbol keys" do
    result_sym = @partials[:missing_key]
    assert_match(/missing_key/, result_sym)
  end

  test "method_missing with block captures via template" do
    @partials.my_partial { "some content" }
    result = @partials["my_partial"]
    # The template's capture method is called, result is whatever capture returns
    assert_not_nil result
  end

  test "method_missing without block returns partial value" do
    result = @partials.unknown_partial
    assert_match(/unknown_partial/, result)
    assert_match(/not found/, result)
  end
end

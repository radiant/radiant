require 'test/unit'
require 'radius'

class RadiusOrdStringTest < Test::Unit::TestCase

  def test_string_slice_integer
    str = Radius::OrdString.new "abc"
    assert_equal str[0], 97
    assert_equal str[1], 98
    assert_equal str[2], 99
  end

  def test_string_slice_range
    str = Radius::OrdString.new "abc"
    assert_equal str[0..-1], "abc"
  end

end
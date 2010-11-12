require 'test/unit'
require 'radius'

class RadiusUtilityTest < Test::Unit::TestCase
  
  def test_symbolize_keys
    h = Radius::Utility.symbolize_keys({ 'a' => 1, :b => 2 })
    assert_equal h[:a], 1
    assert_equal h[:b], 2
  end
  
  def test_impartial_hash_delete
    h = { 'a' => 1, :b => 2 }
    assert_equal Radius::Utility.impartial_hash_delete(h, :a), 1
    assert_equal Radius::Utility.impartial_hash_delete(h, 'b'), 2
    assert_equal h.empty?, true
  end
  
  def test_constantize
    assert_equal Radius::Utility.constantize('String'), String
  end
  
  def test_camelize
    assert_equal Radius::Utility.camelize('ab_cd_ef'), 'AbCdEf'
  end

  def test_array_to_s
    assert_equal Radius::Utility.array_to_s(['a', 1, [:c]]), 'a1c'
  end
end
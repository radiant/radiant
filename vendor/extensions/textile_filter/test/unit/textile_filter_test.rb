require File.dirname(__FILE__) + '/../test_helper'

class TextileFilterTest < Test::Unit::TestCase

  def test_filter_name
    assert_equal 'Textile', TextileFilter.filter_name
  end
  
  def test_filter
    assert_equal '<h1>Test</h1>', TextileFilter.filter('h1. Test')
  end  

end
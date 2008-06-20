require File.dirname(__FILE__) + '/../test_helper'

class SmartyPantsFilterTest < Test::Unit::TestCase

  def test_filter_name
    assert_equal 'SmartyPants', SmartyPantsFilter.filter_name
  end
  
  def test_filter
    assert_equal "<h1 class=\"headline\">Radiant&#8217;s &#8220;filters&#8221; rock!</h1>", 
      SmartyPantsFilter.filter("<h1 class=\"headline\">Radiant's \"filters\" rock!</h1>")
  end  

end
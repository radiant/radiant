require File.dirname(__FILE__) + '/../test_helper'

class MarkdownFilterTest < Test::Unit::TestCase

  def test_filter_name
    assert_equal 'Markdown', MarkdownFilter.filter_name
  end

  def test_filter
    assert_equal '<p><strong>strong</strong></p>', MarkdownFilter.filter('**strong**')
  end
  
  def test_filter_with_quotes
    assert_equal "<h1>Radiant&#8217;s &#8220;filters&#8221; rock!</h1>", 
      MarkdownFilter.filter("# Radiant's \"filters\" rock!")
  end

end
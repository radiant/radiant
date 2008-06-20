require File.dirname(__FILE__) + '/../test_helper'

class ArchivePageTest < Test::Unit::TestCase
  fixtures :pages
  test_helper :pages

  def test_child_url
    child = pages(:article)
    assert_equal '/archive/2000/05/01/article/', child.url
  end

  def test_child_url__nil_published_at_date
    child = pages(:article_draft)
    assert_nil child.published_at
    assert_equal '/archive/' + Time.now.strftime('%Y/%m/%d') + '/draft/', child.url
  end

  def test_find__year_index
    expected = pages(:year_index)
    year_index = Page.find_by_url('/archive/2000/')
    assert_equal expected, year_index
  end
  def test_find__month_index
    expected = pages(:month_index)
    month_index = Page.find_by_url('/archive/2000/06/')
    assert_equal expected, month_index
  end
  def test_find__day_index
    expected = pages(:day_index)
    day_index = Page.find_by_url('/archive/2000/06/09/')
    assert_equal expected, day_index
  end
  
  # Extracted from other unit tests
  def test_find_by_url_with_archive
    @page = pages(:homepage)
    assert_equal pages(:article), @page.find_by_url('/archive/2000/05/01/article/')
  end

end

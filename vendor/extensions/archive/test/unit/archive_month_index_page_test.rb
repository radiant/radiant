require File.dirname(__FILE__) + '/../test_helper'

class ArchiveMonthIndexPageTest < Test::Unit::TestCase
  fixtures :pages
  test_helper :pages, :archive_index, :render

  def setup
    @page = pages(:month_index)
  end
  
  def test_children_tag
    assert_renders 'article-2 article-3 ', '<r:archive:children:each><r:slug /> </r:archive:children:each>', '/archive/2000/06/'
    assert_renders 'article-2 article-3 ', '<r:archive:children:each><r:slug /> </r:archive:children:each>', '/archive/2000/06'
  end
  
  def test_title_tag
    assert_renders 'June 2000 Archive', '<r:title />', '/archive/2000/06/'
  end
  
  include ArchiveIndexTests
  
end
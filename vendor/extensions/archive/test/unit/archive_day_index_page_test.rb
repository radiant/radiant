require File.dirname(__FILE__) + '/../test_helper'

class ArchiveDayIndexPageTest < Test::Unit::TestCase
  fixtures :pages
  test_helper :pages, :archive_index, :render

  def setup
    @page = pages(:day_index)
  end

  def test_children_tag
    assert_renders 'article-2 ', '<r:archive:children:each><r:slug /> </r:archive:children:each>', '/archive/2000/06/09/'
    assert_renders 'article-2 ', '<r:archive:children:each><r:slug /> </r:archive:children:each>', '/archive/2000/06/09'
  end
  
  def test_title_tag
    assert_renders 'June 09, 2000 Archive', '<r:title />', '/archive/2000/06/09/'
  end
  
  include ArchiveIndexTests
  
end
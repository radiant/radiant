require File.dirname(__FILE__) + '/../test_helper'

class ArchiveYearIndexPageTest < Test::Unit::TestCase
  fixtures :pages
  test_helper :pages, :archive_index, :render
  
  def setup
    @page = pages(:year_index)
  end
  
  def test_children_tag
    assert_renders 'article article-2 article-3 article-4 ', '<r:archive:children:each><r:slug /> </r:archive:children:each>', '/archive/2000/'
    assert_renders 'article article-2 article-3 article-4 ', '<r:archive:children:each><r:slug /> </r:archive:children:each>', '/archive/2000'
  end
  
  def test_title_tag
    assert_renders '2000 Archive', '<r:title />', '/archive/2000/'
  end
    
  include ArchiveIndexTests

end
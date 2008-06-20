module ArchiveIndexTestHelper
  module ArchiveIndexTests
    
    def test_page_virtual?
      assert_equal true, @page.virtual?
    end
    
    def test_first_tag__index
      assert_renders 'unimplemented', '<r:archive:children:first><r:slug /></r:archive:children:first>'
    end

    def test_last_tag__index
      assert_renders 'unimplemented', '<r:archive:children:last><r:slug /></r:archive:children:last>'
    end

    def test_count_tag__index
      assert_renders 'unimplemented', '<r:archive:children:count />'
    end
    
    def test_year_tag
      assert_renders '2000', '<r:archive:year />', '/archive/2000/'
    end
    
    def test_month_tag
      assert_renders 'June', '<r:archive:month />', '/archive/2000/06/'
    end
    
    def test_day_tag
      assert_renders '9', '<r:archive:day />', '/archive/2000/06/09/'
    end
    
    def test_day_of_week_tag
      assert_renders 'Friday', '<r:archive:day_of_week />', '/archive/2000/06/09/'
    end
    
  end
end
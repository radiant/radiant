require File.dirname(__FILE__) + '/../test_helper'

class ArchiveExtensionTest < Test::Unit::TestCase
    
  def test_initialization
    assert_equal File.join(File.expand_path(RADIANT_ROOT), 'vendor', 'extensions', 'archive'), ArchiveExtension.root
    assert_equal 'Archive', ArchiveExtension.extension_name
  end
  
  def test_should_define_pages
    assert defined?(ArchivePage)
    assert defined?(ArchiveYearIndexPage)
    assert defined?(ArchiveMonthIndexPage)
    assert defined?(ArchiveDayIndexPage)
  end
end

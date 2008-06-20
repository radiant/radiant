# Uncomment this if you reference any of your controllers in activate
# require_dependency 'application'

class ArchiveExtension < Radiant::Extension
  version "1.0"
  description "Provides Archive page types behave similar to a blog or news archive."
  url "http://dev.radiantcms.org/"
    
  def activate
    ArchivePage
    ArchiveYearIndexPage
    ArchiveMonthIndexPage
    ArchiveDayIndexPage
  end
  
  def deactivate
  end
  
end

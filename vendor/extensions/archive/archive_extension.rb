# Uncomment this if you reference any of your controllers in activate
# require_dependency 'application'

class ArchiveExtension < Radiant::Extension
  version "1.0"
  description "Provides page types for news or blog archives."
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

begin
  require 'rdiscount'
  BlueCloth = RDiscount
rescue LoadError
  # If RDiscount is not available, use packaged BlueCloth
  $LOAD_PATH.unshift "#{File.dirname(__FILE__)}/vendor/bluecloth/lib"
  require 'bluecloth'
end

begin
  require 'rubypants'
rescue LoadError
  # If rubypants gem is not available, use packaged version
  $LOAD_PATH.unshift "#{File.dirname(__FILE__)}/vendor/rubypants"
  retry
end

class MarkdownFilterExtension < Radiant::Extension
  version "1.0"
  description "Allows you to compose page parts or snippets using the Markdown or SmartyPants text filters."
  url "http://daringfireball.net/projects/markdown/"

  def activate
    MarkdownFilter
    SmartyPantsFilter
    Page.send :include, MarkdownTags
  end
end
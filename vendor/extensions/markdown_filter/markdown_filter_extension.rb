begin
  require 'rdiscount'
rescue LoadError
  # If RDiscount is not available, use packaged BlueCloth
  $LOAD_PATH.unshift "#{File.dirname(__FILE__)}/vendor/kramdown/lib"
  require 'kramdown'
end

class MarkdownFilterExtension < Radiant::Extension
  version "1.0"
  description "Allows you to compose page parts or snippets using the Markdown text filter."
  url "http://daringfireball.net/projects/markdown/"

  def activate
    MarkdownFilter
    Page.send :include, MarkdownTags
  end
end
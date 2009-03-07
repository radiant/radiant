class TextileFilterExtension < Radiant::Extension
  version "1.0"
  description "Allows you to compose page parts or snippets using the Textile text filter."
  url "http://textism.com/tools/textile/"

  def activate
    TextileFilter
    Page.send :include, TextileTags
  end
end
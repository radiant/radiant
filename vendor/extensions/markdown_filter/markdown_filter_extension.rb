class MarkdownFilterExtension < Radiant::Extension
  version "1.0"
  description "Allows you to compose page parts or snippets using the Markdown or SmartyPants text filters."
  url "http://daringfireball.net/projects/markdown/"
  
  def activate
    MarkdownFilter
    SmartyPantsFilter
  end
end
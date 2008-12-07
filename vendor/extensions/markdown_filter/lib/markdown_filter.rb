class MarkdownFilter < TextFilter
  description_file File.dirname(__FILE__) + "/../markdown.html"
  def filter(text)
    RubyPants.new(BlueCloth.new(text).to_html).to_html
  end
end
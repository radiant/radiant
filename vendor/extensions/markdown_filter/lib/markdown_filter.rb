class MarkdownFilter < TextFilter
  description_file File.dirname(__FILE__) + "/../markdown.html"
  def filter(text)
    if defined? RDiscount
      RDiscount.new(text, :smart).to_html
    else
      RubyPants.new(BlueCloth.new(text).to_html).to_html
    end
  end
end
class MarkdownFilter < TextFilter
  description_file File.dirname(__FILE__) + "/../markdown.html"
  def filter(text)
    if defined? RDiscount
      RDiscount.new(text, :smart).to_html
    else
      RubyPants.new(Kramdown::Document.new(text, {
        :auto_ids => false,
        :parse_block_html => false,
        :coderay => nil
      }).to_html).to_html
    end
  end
end
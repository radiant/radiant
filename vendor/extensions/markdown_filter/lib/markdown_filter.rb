class MarkdownFilter < TextFilter
  description_file File.dirname(__FILE__) + "/../markdown.html"
  def filter(text)
    if defined? RDiscount
      RDiscount.new(text, :smart).to_html
    else
      Kramdown::Document.new(text, {
        :auto_ids => false,
        :coderay_line_numbers => nil,
        :coderay_css => :class
      }).to_html
    end
  end
end
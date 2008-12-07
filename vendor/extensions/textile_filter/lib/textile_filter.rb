class TextileFilter < TextFilter
  description_file File.dirname(__FILE__) + "/../textile.html"
  def filter(text)
    RedCloth.new(text).to_html
  end
end
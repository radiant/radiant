class SmartyPantsFilter < TextFilter
  filter_name "SmartyPants"
  description_file File.dirname(__FILE__) + "/../smartypants.html"   
  def filter(text)
    RubyPants.new(text).to_html
  end
end
unless defined?(TextileFilter)
  class TextileFilter < TextFilter
    def filter(text)
      text + ' - Filtered with TEXTILE!'
    end
  end
end
unless defined?(MarkdownFilter)
  class MarkdownFilter < TextFilter
    def filter(text)
      text + ' - Filtered with MARKDOWN!'
    end
  end
end

class MarkupPagesDataset < Dataset::Base
  uses :home_page
  
  def load
    create_page "Textile" do
      create_page_part :textile_body, :name => "body", :filter_id => "Textile", :content => "Some *Textile* content."
    end
    create_page "Markdown" do
      create_page_part :markdown_body, :name => "body", :filter_id => "Markdown", :content => "Some **Markdown** content."
    end
  end
  
end
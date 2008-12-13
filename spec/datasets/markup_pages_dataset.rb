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
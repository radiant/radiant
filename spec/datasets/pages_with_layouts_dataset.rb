class PagesWithLayoutsDataset < Dataset::Base
  uses :pages, :layouts
  
  def load
    Page.update_all :layout_id => layouts(:main)
    create_page "Inherited Layout"
    create_page "UTF8", :layout_id => layouts(:utf8)
  end
  
end
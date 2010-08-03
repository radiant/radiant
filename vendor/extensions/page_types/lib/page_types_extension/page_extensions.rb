module PageTypesExtension::PageExtensions
  def default_child
    Page
  end
  def allowed_children
    [default_child, *Page.descendants.sort_by(&:name)]
  end
end
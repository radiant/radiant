module PageTypesHelper
  def self.included(base)
    base.alias_method_chain :children_for, :roles
  end

  def child_link_for(page)
    case children_for(page).size
    when 0
      content_tag :span, image('plus_disabled') + ' ' + t('add_child'), :class => 'action disabled'
    when 1
      link_to image('plus') + ' ' + t('add_child'), new_admin_page_child_path(page, :page_class => children_for(page).first), :class => "action"
    else
      link_to image('plus') + ' ' + t('add_child'), "#allowed_children_#{page.id}", :class => "action dropdown"
    end
  end

  def child_menu_for(page)
    children = children_for(page)
    return nil if children.size < 2
    children.unshift(children.delete(page.default_child), :separator) if children.include?(page.default_child)
    name_for = proc { |p| (name = p.name.to_name('Page')).blank? ? t('normal_page') : name }
    content_tag :ul, :class => 'menu', :id => "allowed_children_#{page.id}" do
      children.map do |child|
        if child == :separator
          content_tag :li, nil, :class => 'separator'
        else
          content_tag :li, link_to(name_for[child], new_admin_page_child_path(page, :page_class => child))
        end
      end
    end
  end

  def children_for(page)
    page.allowed_children
  end

  def children_for_with_roles(page)
    children = children_for_without_roles(page)
    children.reject! { |p| p.new.virtual? } unless admin?
    children
  end
end
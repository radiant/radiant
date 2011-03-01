module Admin::NodeHelper

  def render_node(page, locals = {})
    @current_node = page
    locals.reverse_merge!(:level => 0, :simple => false).merge!(:page => page)
    render :partial => 'admin/pages/node', :locals =>  locals
  end

  def homepage
    @homepage ||= Page.find_by_parent_id(nil)
  end

  def clean_page_description(page)
    page.description.to_s.strip.gsub(/\t/,'').gsub(/\s+/,' ')
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
          content_tag :li, link_to(name_for[child], new_admin_page_child_path(page, :page_class => child), :title => clean_page_description(child))
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
  alias_method_chain :children_for, :roles

  def show_all?
    @controller.action_name == 'remove'
  end

  def expanded_rows
    unless @expanded_rows
      @expanded_rows = case
      when rows = cookies[:expanded_rows]
        rows.split(',').map { |x| Integer(x) rescue nil }.compact
      else
        []
      end

      if homepage and !@expanded_rows.include?(homepage.id)
        @expanded_rows << homepage.id
      end
    end
    @expanded_rows
  end

  def expanded
    show_all? || expanded_rows.include?(@current_node.id)
  end

  def padding_left(level)
    (level * 23) + 9
  end

  def children_class
    unless @current_node.children.empty?
      if expanded
        " children_visible"
      else
        " children_hidden"
      end
    else
      " no_children"
    end
  end

  def virtual_class
    @current_node.virtual? ? " virtual": ""
  end

  def expander(level)
    unless @current_node.children.empty? or level == 0
      image((expanded ? "collapse" : "expand"),
            :class => "expander", :alt => 'toggle children',
            :title => '')
    else
      ""
    end
  end

  def icon
    icon_name = @current_node.virtual? ? 'virtual_page' : 'page'
    image(icon_name, :class => "icon", :alt => '', :title => '')
  end

  def node_title
    %{<span class="title">#{ h(@current_node.title) }</span>}
  end

  def page_type
    display_name = @current_node.class.display_name
    if display_name == 'Page'
      ""
    else
      %{<span class="info">(#{ h(display_name) })</span>}
    end
  end

  def spinner
    image('spinner.gif',
            :class => 'busy', :id => "busy_#{@current_node.id}",
            :alt => "",  :title => "",
            :style => 'display: none;')
  end
end

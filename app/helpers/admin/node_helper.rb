module Admin::NodeHelper

  def render_node(page, locals = {})
    @current_node = page
    locals.reverse_merge!(:level => 0, :simple => false).merge!(:page => page)
    render :partial => 'node', :locals =>  locals
  end

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
        " children-visible"
      else
        " children-hidden"
      end
    else
      " no-children"
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
    image(icon_name, :class => "icon", :alt => 'page-icon', :title => '')
  end

  def node_title
    %{<span class="title">#{ h(@current_node.title) }</span>}
  end

  def page_type
    display_name = @current_node.class.display_name
    if display_name == 'Page'
      ""
    else
      %{<small class="info">(#{ h(display_name) })</small>}
    end
  end

  def spinner
    image('spinner.gif',
            :class => 'busy', :id => "busy-#{@current_node.id}",
            :alt => "",  :title => "",
            :style => 'display: none;')
  end
end

module MenuRenderer

  def exclude(*type_names)
    @excluded_class_names ||= []
    @excluded_class_names.concat(type_names).uniq!
  end
  module_function :exclude

  def excluded_class_names
    MenuRenderer.instance_variable_get(:@excluded_class_names)
  end

  module_function :excluded_class_names
  public :excluded_class_names

  def view=(val)
    @view = val
  end

  def view
    @view
  end

  def additional_menu_features?
    @additional_menu_features ||= (menu_renderer_module_name != 'MenuRenderer' && Object.const_defined?(menu_renderer_module_name))
  end

  def menu_renderer_module_name
    simple_name = self.class_name.to_s.sub('Page','')
    "#{simple_name}MenuRenderer"
  end

  def menu_renderer_modules
    [Object.const_get(menu_renderer_module_name)]
  end

  def allowed_child_classes
    (allowed_children_cache.to_s.split(',') - Array(excluded_class_names)).map do |name|
      begin
        name.constantize
      rescue LoadError, NameError => e
        nil
      end
    end.compact
  end


  def default_child_item
    menu_item(default_child)
  end

  def separator_item
    view.content_tag :li, '', :class => 'separator'
  end

  def child_items
    (allowed_child_classes - [self.class.default_child]).map do |child|
      menu_item(child)
    end
  end

  def menu_items
    [default_child_item, separator_item] + child_items
  end

  def menu_list
    view.content_tag :ul, menu_items.join, :class => 'menu', :id => "allowed_children_#{id}"
  end

  def remove_link
    view.link_to view.image('minus') + ' ' + I18n.t('remove'), view.remove_admin_page_url(self), :class => "action"
  end

  def remove_option
    remove_link
  end

  def add_child_disabled?
    allowed_child_classes.size == 0
  end

  def disabled_add_child_link
    view.content_tag :span, view.image('plus_disabled') + ' ' + I18n.t('add_child'), :class => 'action disabled'
  end

  def add_child_link
    view.link_to((view.image('plus') + ' ' + I18n.t('add_child')), view.new_admin_page_child_path(self, :page_class => default_child.name), :class => "action")
  end

  def add_child_link_with_menu_hook
    view.link_to((view.image('plus') + ' ' + I18n.t('add_child')), "#allowed_children_#{id}", :class => "action dropdown")
  end

  def add_child_menu
    menu_list
  end

  def add_child_link_with_menu
    add_child_link_with_menu_hook + add_child_menu
  end

  def add_child_option
    if add_child_disabled?
      disabled_add_child_link
    else
      if allowed_child_classes.size == 1
        add_child_link
      else
        add_child_link_with_menu
      end
    end
  end

  private

  def clean_page_description(page_class)
    page_class.description.to_s.strip.gsub(/\t/,'').gsub(/\s+/,' ')
  end

  def menu_item(child_class)
    view.content_tag(:li, menu_link(child_class))
  end

  def menu_link(child_class)
    title = clean_page_description(child_class)
    path = view.new_admin_page_child_path(self, :page_class => child_class.name)
    text = link_text_for_child_class(child_class.name)
    view.link_to(text, path, :title => title)
  end
  
  def link_text_for_child_class(given_class_name)
    translation_key = if given_class_name == 'Page' || given_class_name.blank?
      'normal_page'
    else
      given_class_name.sub('Page','').underscore
    end
    fallback = given_class_name == 'Page' ? 'Page' : given_class_name.sub('Page','').titleize
    I18n.t(translation_key, :default => fallback)
  end
end
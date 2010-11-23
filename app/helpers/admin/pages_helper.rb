module Admin::PagesHelper
  include Admin::NodeHelper
  include Admin::ReferencesHelper
  
  def class_of_page
    @page.class
  end
  
  def filter
    @page.parts.empty? ? nil : @page.parts.first.filter
  end
  
  def meta_errors?
    !!(@page.errors[:slug] or @page.errors[:breadcrumb])
  end

  def default_filter_name
    @page.parts.empty? ? "" : @page.parts[0].filter_id
  end

  def homepage
    @homepage ||= Page.find_by_parent_id(nil)
  end
  
  def status_to_display
    @page.status_id = 100 if @page.status_id == 90
    @display_status = Status.selectable.map{ |s| [I18n.translate(s.name.downcase), s.id] }
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

  def clean_page_description(page)
    page.description.to_s.strip.gsub(/\t/,'').gsub(/\s+/,' ')
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

  def page_edit_javascripts
    <<-CODE
    function addPart(form) {
       if (validPartName()) {
        new Ajax.Updater(
          $('tab_control').down('.pages'),
          '#{admin_page_parts_path}',
          {
            asynchronous: true,
            evalScripts: true,
            insertion: 'bottom',
            onComplete: function(request){ partAdded() },
            onLoading: function(request){ partLoading() },
            parameters: Form.serialize(form)
          }
        );
      }
    }
    function removePart() {
      if(confirm('Remove the current part?')) {
        TabControls['tab_control'].removeSelected();
      }
    }
    function partAdded() {
      var tabControl = TabControls['tab_control'];
      $('add_part_busy').hide();
      $('add_part_button').disabled = false;
      $('add_part_popup').closePopup();
      $('part_name_field').value = '';
      tabControl.updateTabs();
      tabControl.select(tabControl.tabs.last());
    }
    function partLoading() {
      $('add_part_button').disabled = true;
      $('add_part_busy').appear();
    }
    function validPartName() {
      var partNameField = $('part_name_field');
      var name = partNameField.value.downcase();
      if (name.blank()) {
        alert('Part name cannot be empty.');
        return false;
      }
      if (TabControls['tab_control'].findTabByCaption(name)) {
        alert('Part name must be unique.');
        return false;
      }
      return true;
    }

    var lastPageType = '#{@page.class.name}';
    var tagReferenceWindows = {};
    function loadTagReference(part) {
      var pageType = $F('page_class_name');
      if (!tagReferenceWindows[pageType])
        tagReferenceWindows[pageType] = new Popup.AjaxWindow("#{admin_reference_path('tags')}?class_name=" + encodeURIComponent(pageType), {reload: false});
      var window = tagReferenceWindows[pageType];
      if(lastPageType != pageType) {
        $('tag_reference_link_' + part).highlight();
        window.show();
      } else {
        window.toggle();
      }
      lastPageType = pageType;
      return false;
    }

    var lastFilter = '#{default_filter_name}';
    var filterWindows = {};
    function loadFilterReference(part) {
      var filter = $F("part_" + part + "_filter_id");
      if (filter != "") {
        if (!filterWindows[filter]) filterWindows[filter] = new Popup.AjaxWindow("#{admin_reference_path('filters')}?filter_name="+encodeURIComponent(filter), {reload: false});
        var window = filterWindows[filter];
        if(lastFilter != filter) {
          window.show();
        } else {
          window.toggle();
        }
        lastFilter = filter;
      } else {
        alert('No documentation for filter.');
      }
      return false;
    }
    CODE
  end
end

module Admin::PagesHelper
  include Admin::NodeHelper
  include Admin::ReferencesHelper
  
  def class_of_page
    @page.class
  end
  
  def filter
    @page.parts.first.filter
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

  def page_edit_javascripts
    <<-CODE
    var last_type = "#{@page.class_name}";
    function load_tag_reference(part) {
      page_type = $F('page_class_name');
      popup = $('tag-reference-popup');
      if(last_type != page_type) {
        url = "#{admin_reference_path(:id => 'tags')}";
        params = "class_name=" + page_type;
        new Effect.Highlight('tag-reference-link-'+ part);
        req = new Ajax.Request(url, { method: 'get', parameters: params, evalScripts: true });
      } else {
         center(popup);
         Element.toggle(popup);
      }
      return false;
    }
    var last_filter = "#{default_filter_name}";
    function load_filter_reference(part) {
      filter_type = $F("part_" + part + "_filter_id");
      popup = $('filter-reference-popup');
      if(last_filter != filter_type) {
        url = "#{admin_reference_path(:id => 'filters')}";
        params = "filter_name=" + filter_type;
        new Effect.Highlight('filter-reference-link-'+ part);
        req = new Ajax.Request(url, { method: 'get', parameters: params, evalScripts: true });
      } else {
        center(popup);
        Element.toggle(popup);
      }
      return false;
    }
    CODE
  end
end

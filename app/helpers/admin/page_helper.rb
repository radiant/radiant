module Admin::PageHelper
  include Admin::NodeHelper
  
  def meta_errors?
    !!(@page.errors[:slug] or @page.errors[:breadcrumb])
  end
  
  def tag_reference(class_name)
    returning String.new do |output|
      class_name.constantize.tag_descriptions.sort.each do |tag_name, description|
        output << render(:partial => "tag_reference", 
            :locals => {:tag_name => tag_name, :description => description})
      end
    end
  end
  
  def filter_reference(filter_name)
    unless filter_name.blank?
      filter_class = (filter_name.gsub(" ", "") + "Filter").constantize
      filter_class.description.blank? ? "There is no documentation on this filter." : filter_class.description
    else
      "There is no filter on the current page part."
    end
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
        url = "#{tag_reference_url}";
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
        url = "#{filter_reference_url}";
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

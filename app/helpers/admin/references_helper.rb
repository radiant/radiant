require "RedCloth"

module Admin::ReferencesHelper
  def tag_reference
    page_class = (params[:class_name].presence || 'Page').constantize
    String.new.tap do |output|
      page_class.tag_descriptions.sort.each do |tag_name, description|
        output << render(:partial => "admin/references/tag_reference",
            :locals => {:tag_name => tag_name,
                        :description =>  begin
                          rc = RedCloth.new(Radiant::Taggable::Util.strip_leading_whitespace(description))
                          rc.hard_breaks = false
                          rc.to_html
                        end
                       })
      end
    end.html_safe
  end

  def filter_reference
    unless filter.blank?
      if filter.description.blank?
        "There is no documentation on this filter."
      else
        filter.description
      end
    else
      "There is no filter on the current page part."
    end
  end

  def _display_name
    case params[:type]
    when 'filters'
      filter ? filter.filter_name : t('select.none')
    when 'tags'
      page_class = (params[:class_name].presence || 'Page').constantize
      page_class.display_name
    end
  end

  def filter
    @filter ||= begin
      TextFilter.find_descendant(params[:filter_name])
    end
  end

  def class_of_page
    @page_class ||= (params[:class_name].blank? ? 'Page' : params[:class_name]).constantize
  end

end

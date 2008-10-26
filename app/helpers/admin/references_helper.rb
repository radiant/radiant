module Admin::ReferencesHelper
  def tag_reference
    class_name = params[:class_name] || 'Page'
    returning String.new do |output|
      class_name.constantize.tag_descriptions.sort.each do |tag_name, description|
        output << render(:partial => "tag_reference", 
            :locals => {:tag_name => tag_name, :description => description})
      end
    end
  end
  
  def filter_reference
    filter_name = params[:filter_name]
    unless filter_name.blank?
      filter_class = (filter_name.gsub(" ", "") + "Filter").constantize
      filter_class.description.blank? ? "There is no documentation on this filter." : filter_class.description
    else
      "There is no filter on the current page part."
    end
  end
  
end

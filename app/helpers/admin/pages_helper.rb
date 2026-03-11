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
    return false unless @page
    @page.errors[:slug].any? || @page.errors[:breadcrumb].any?
  end

  def default_filter_name
    @page.parts.empty? ? "" : @page.parts[0].filter_id
  end

  def status_to_display
    @page.status_id = 100 if @page.status_id == 90
    @display_status = Status.selectable.map{ |s| [I18n.translate(s.name.downcase), s.id] }
  end

  def clean_page_description(page)
    page.description.to_s.strip.gsub(/\t/,'').gsub(/\s+/,' ')
  end
end

module ApplicationHelper
  include LocalTime
  include Admin::RegionsHelper
  include Radiant::LegacyRoutes

  def config
    Radiant::Config
  end

  def default_page_title
    title + ' - ' + subtitle
  end

  def title
    config['admin.title'] || 'Radiant CMS'
  end

  def subtitle
    config['admin.subtitle'] || 'Publishing for Small Teams'
  end

  def logged_in?
    !current_user.nil?
  end
  
  def onsubmit_status(model)
    model.new_record? ? "Creating #{model.class.name.downcase}&#8230;" : "Saving changes&#8230;"
  end
  
  def save_model_button(model, options = {})
    options[:label] ||= model.new_record? ?
      "Create #{model.class.name}" : "Save Changes"
    options[:class] ||= "button"
    options[:accesskey] ||= 'S'
    submit_tag options.delete(:label), options
  end

  def save_model_and_continue_editing_button(model)
    submit_tag 'Save and Continue Editing', :name => 'continue', :class => 'button', :accesskey => "s"
  end

  # Redefine pluralize() so that it doesn't put the count at the beginning of
  # the string.
  def pluralize(count, singular, plural = nil)
    if count == 1
      singular
    elsif plural
      plural
    else
      ActiveSupport::Inflector.pluralize(singular)
    end
  end

  def current_item?(item)
    if item.tab && item.tab.many? {|i| current_url?(i.relative_url) }
      # Accept only stricter URL matches if more than one matches
      current_page?(item.url)
    else
      current_url?(item.relative_url)
    end
  end

  def current_tab?(tab)
    @current_tab ||= tab if tab.any? {|item| current_url?(item.relative_url) }
    @current_tab == tab
  end
  
  def current_url?(options)
    url = case options
    when Hash
      url_for options
    else
      options.to_s
    end
    request.request_uri =~ Regexp.new('^' + Regexp.quote(clean(url)))
  end

  def clean(url)
    uri = URI.parse(url)
    uri.path.gsub(%r{/+}, '/').gsub(%r{/$}, '')
  end

  def nav_link_to(name, options)
    if current_url?(options)
      %{<strong>#{ link_to name, options }</strong>}
    else
      link_to name, options
    end
  end

  def admin?
    current_user and current_user.admin?
  end

  def designer?
    current_user and (current_user.designer? or current_user.admin?)
  end

  def focus(field_name)
    javascript_tag "Field.activate('#{field_name}');"
  end

  def updated_stamp(model)
    unless model.new_record?
      updated_by = (model.updated_by || model.created_by)
      name = updated_by ? updated_by.name : nil
      time = (model.updated_at || model.created_at)
      if name or time
        html = %{<p class="updated_line">Last updated } 
        html << %{by <strong>#{name}</strong> } if name
        html << %{at #{timestamp(time)}} if time
        html << %{</p>}
        html
      end
    end
  end

  def timestamp(time)
    time.strftime("%I:%M %p on %B %e, %Y").sub("AM", 'am').sub("PM", 'pm')
  end 
  
  def meta_visible(symbol)
    v = case symbol
    when :meta_more
      not meta_errors?
    when :meta, :meta_less
      meta_errors?
    end
    v ? {} : {:class => "hidden"}
  end

  def meta_errors?
    false
  end
  
  def meta_label
    meta_errors? ? 'Less' : 'More'
  end

  def toggle_javascript_for(id)
    "Element.toggle('#{id}'); Element.toggle('more-#{id}'); Element.toggle('less-#{id}'); return false;"
  end

  def image(name, options = {})
    image_tag(append_image_extension("admin/#{name}"), options)
  end

  def image_submit(name, options = {})
    image_submit_tag(append_image_extension("admin/#{name}"), options)
  end

  def admin
    Radiant::AdminUI.instance
  end

  def filter_options_for_select(selected=nil)
    options_for_select([['<none>', '']] + TextFilter.descendants.map { |s| s.filter_name }.sort, selected)
  end

  def body_classes
    @body_classes ||= []
  end

  def nav_tabs
    admin.nav
  end
  
  def stylesheet_and_javascript_overrides
    overrides = ''
    if File.exist?("#{Rails.root}/public/stylesheets/admin/overrides.css") || File.exist?("#{Rails.root}/public/stylesheets/sass/admin/overrides.sass")
      overrides << stylesheet_link_tag('admin/overrides')
    end
    if File.exist?("#{Rails.root}/public/javascripts/admin/overrides.js")
      overrides << javascript_include_tag('admin/overrides')
    end
    overrides
  end

  private

    def append_image_extension(name)
      unless name =~ /\.(.*?)$/
        name + '.png'
      else
        name
      end
    end

end

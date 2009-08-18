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

    submit_tag options.delete(:label), options
  end
  
  def save_model_and_continue_editing_button(model)
    submit_tag 'Save and Continue Editing', :name => 'continue', :class => 'button'
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
  
  def links_for_navigation
    tabs = admin.tabs
    links = tabs.map do |tab|
      nav_link_to(tab.name, File.join(ActionController::Base.relative_url_root || '', tab.url)) if tab.shown_for?(current_user)
    end.compact
    links.join(separator)
  end
  
  def separator
    %{ <span class="separator"> | </span> }
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
  
  def developer?
    current_user and (current_user.developer? or current_user.admin?)
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
    v ? {} : {:style => "display:none"}
  end
  
  def meta_errors?
    false
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
  
  # The NavTab Class holds the structure of a navigation tab (including
  # its sub-nav items).
  class NavTab < Array
    attr_reader :name, :proper_name
    
    def initialize(name, proper_name)
      @name, @proper_name = name, proper_name
    end
    
    def [](id)
      unless id.kind_of? Fixnum
        self.find {|subnav_item| subnav_item.name.to_s == id.to_s }
      else
        super
      end
    end
  end
  
  # Simple structure for storing the properties of a tab's sub items.
  class NavSubItem
    attr_reader :name, :proper_name, :url
    
    def initialize(name, proper_name, url = "#")
      @name, @proper_name, @url = name, proper_name, url
    end
  end
  
  def nav_tabs
    content = NavTab.new(:content, "Content")
    content << NavSubItem.new(:pages, "Pages", admin_pages_path)
    content << NavSubItem.new(:snippets, "Snippets", admin_snippets_path)
    
    design = NavTab.new(:design, "Design")
    design << NavSubItem.new(:layouts, "Layouts", admin_layouts_path)
    design << NavSubItem.new(:stylesheets, "Stylesheets", "#")
    design << NavSubItem.new(:javascripts, "Javascripts", "#")
    
    # media = NavTab.new(:assets, "Assets")
    # media << NavSubItem.new(:all, "All", "/admin/assets/")
    # media << NavSubItem.new(:all, "Unattached", "/admin/assets/unattached/")
    
    settings = NavTab.new(:settings, "Settings")
    settings << NavSubItem.new(:general, "Personal", edit_admin_preferences_path)
    settings << NavSubItem.new(:users, "Users", admin_users_path)
    settings << NavSubItem.new(:extensions, "Extensions", admin_extensions_path)
    
    [content, design, settings]
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

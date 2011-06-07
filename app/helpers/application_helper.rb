module ApplicationHelper
  include LocalTime
  include Admin::RegionsHelper
  
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
    model.new_record? ? t('creating_status', :model => t(model.class.name.downcase)) : "#{I18n.t('saving_changes')}&#8230;"
  end
  
  def save_model_button(model, options = {})
    model_name = model.class.name.underscore
    human_model_name = model_name.humanize.titlecase
    options[:label] ||= model.new_record? ?
      t('buttons.create', :name => t(model_name, :default => human_model_name), :default => 'Create ' + human_model_name) :
      t('buttons.save_changes', :default => 'Save Changes')
    options[:class] ||= "button"
    options[:accesskey] ||= 'S'
    submit_tag options.delete(:label), options
  end
  
  def save_model_and_continue_editing_button(model)
    submit_tag t('buttons.save_and_continue'), :name => 'continue', :class => 'button', :accesskey => "s"
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
      %{<strong>#{ link_to translate_with_default(name), options }</strong>}
    else
      link_to translate_with_default(name), options
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
        html = %{<p class="updated_line">#{t('timestamp.last_updated')} } 
        html << %{#{t('timestamp.by')} <strong>#{name}</strong> } if name
        html << %{#{t('timestamp.at')} #{timestamp(time)}} if time
        html << %{</p>}
        html
      end
    end
  end
  
  def timestamp(time)
    # time.strftime("%I:%M %p on %B %e, %Y").sub("AM", 'am').sub("PM", 'pm')
    I18n.localize(time, :format => :timestamp)    
  end 
  
  def meta_visible(symbol)
    v = case symbol
    when :meta_more
      not meta_errors?
    when :meta, :meta_less
      meta_errors?
    end
    v ? {} : {:style => "display: none"}
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
    options_for_select([[t('select.none'), '']] + TextFilter.descendants_names, selected)
  end
  
  def body_classes
    @body_classes ||= []
  end
  
  def nav_tabs
    admin.nav
  end
  
  def translate_with_default(name)
    t(name.underscore.downcase, :default => name)
  end
  
  def available_locales_select
    [[t('select.default'),'']] + Radiant::AvailableLocales.locales
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
  
  # Returns a Gravatar URL associated with the email parameter.
  # See: http://douglasfshearer.com/blog/gravatar-for-ruby-and-ruby-on-rails
  def gravatar_url(email, options={})
    # Default to highest rating. Rating can be one of G, PG, R X.
    options[:rating] ||= "G"
    
    # Default size of the image.
    options[:size] ||= "32px"
    
    # Default image url to be used when no gravatar is found
    # or when an image exceeds the rating parameter.
    default_avatar_url = "#{request.protocol}#{request.host_with_port}/images/admin/avatar_#{([options[:size].to_i] * 2).join('x')}.png"
    options[:default] ||= default_avatar_url
    
    unless email.blank?
      # Build the Gravatar url.
      url = 'http://www.gravatar.com/avatar.php?'
      url << "gravatar_id=#{Digest::MD5.new.update(email)}" 
      url << "&rating=#{options[:rating]}" if options[:rating]
      url << "&size=#{options[:size]}" if options[:size]
      url << "&default=#{options[:default]}" if options[:default]
      url
    else
      default_avatar_url
    end
  end
  
  # returns the usual set of pagination links.
  # options are passed through to will_paginate 
  # and a 'show all' depagination link is added if relevant.
  def pagination_for(list, options={})
    if list.respond_to? :total_pages
      options = {
        :max_per_page => config['pagination.max_per_page'] || 500,
        :depaginate => true
      }.merge(options.symbolize_keys)
      depaginate = options.delete(:depaginate)                                     # supply :depaginate => false to omit the 'show all' link
      depagination_limit = options.delete(:max_per_page)                           # supply :max_per_page => false to include the 'show all' link no matter how large the collection
      html = will_paginate(list, will_paginate_options.merge(options))
      if depaginate && list.total_pages > 1 && (!depagination_limit.blank? || list.total_entries <= depagination_limit.to_i)
        html << content_tag(:div, link_to(t('show_all'), :pp => 'all'), :class => 'depaginate')
      elsif depaginate && list.total_entries > depagination_limit.to_i
        html = content_tag(:div, link_to("paginate", :p => 1), :class => 'pagination')
      end
      html
    end
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

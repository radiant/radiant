module Admin::ConfigurationHelper
  # Defines helper methods for use in the admin interface when displaying or editing configuration.

  # Renders the setting as label and value:
  #
  #   show_setting("admin.title")
  #   => <label for="admin_title">Admin title<label><span id="admin_title">Radiant CMS</span>
  #
  def show_config(key, options={})
    setting = setting_for(key)
    domkey = key.gsub(/\W/, '_')
    html = ""
    html << content_tag(:label, t("config.#{key}").titlecase, :for => domkey)
    if setting.boolean?
      value = setting.checked? ? t('yes') : t('no')
      html << content_tag(:span, value, :id => domkey, :class => "#{value} #{options[:class]}")
    else
      value = setting.selected_value || setting.value
      html << content_tag(:span, value, :id => domkey, :class => options[:class])
    end
  end
  
  # Renders the setting as label and appropriate input field:
  #
  #   edit_setting("admin.title")
  #   => <label for="admin_title">Admin title<label><input type="text" name="config['admin.title']" id="admin_title" value="Radiant CMS" />
  #
  #   edit_setting("defaults.page.status")
  #   => 
  #   <label for="defaults_page_status">Default page status<label>
  #   <select type="text" name="config['defaults.page.status']" id="defaults_page_status">
  #     <option value="Draft">Draft</option>
  #     ...
  #   </select>
  #
  #   edit_setting("user.allow_password_reset?")
  #   => <label for="user_allow_password_reset_">Admin title<label><input type="checkbox" name="config['user.allow_password_reset?']" id="user_allow_password_reset_" value="1" checked="checked" />
  #
  def edit_config(key, options={})
    setting = setting_for(key)
    domkey = key.gsub(/\W/, '_')
    name = "config[#{key}]"
    title = t("config.#{key}").titlecase
    value = params[key.to_sym].nil? ? setting.value : params[key.to_sym]
    html = ""
    if setting.boolean?
      html << check_box_tag(name, 1, value, :class => 'setting', :id => domkey)
      html << content_tag(:label, title, :class => 'checkbox', :for => domkey)
    elsif setting.selector?
      html << content_tag(:label, title, :for => domkey)
      html << select_tag(name, options_for_select(setting.definition.selection, value), :class => 'setting', :id => domkey)
    else
      html << content_tag(:label, title, :for => domkey)
      html << text_field_tag(name, value, :class => 'textbox', :id => domkey)
    end
    html = %{<span class="error-with-field">#{html} <span class="error">#{[setting.errors.on(:value)].flatten.first}</span></span>} if setting.errors.any?
    html
  end
  
  def setting_for(key)
    @config ||= {}    # normally initialized in Admin::ConfigurationController
    @config[key] ||= Radiant.config.find_or_create_by_key(key)
  end
  
  def definition_for(key)
    if setting = setting_for(key)
      setting.definition
    end
  end

end
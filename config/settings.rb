Radiant::Config.prepare do |config|
  config.namespace('admin') do |admin|
    admin.define 'title', :label => 'Admin title', :default => "Radiant CMS"
  end
  config.namespace('defaults', :allow_change => true) do |defaults|
    defaults.define 'locale', :label => 'Default language', :select_from => lambda { Radiant::AvailableLocales.locales }, :allow_blank => true
    defaults.namespace('page') do |page|
      page.define 'parts', :label => 'Default page parts', :notes => 'comma separated list of part names', :default => "Body,Extended"
      page.define 'status', :select_from => lambda { Status.settable_values }, :label => "Default page status", :allow_blank => true, :default => "Draft"
      page.define 'filter', :select_from => lambda { TextFilter.descendants.map { |s| s.filter_name }.sort }, :label => "Default text filter", :allow_blank => true
      page.define 'fields', :label => 'Default page fields', :notes => 'comma separated list of field names'
    end
  end
  config.namespace('site', :allow_change => true) do |site|
    site.define 'title', :label => 'Site title'
    site.define 'domain', :label => 'Site domain'
  end
  config.namespace('users', :allow_change => true) do |users|
    users.define 'allow_password_reset?', :label => 'Allow password reset?'
  end
  config.define 'dev.host', :label => 'Development host', :allow_change => true
  config.define 'local.timezone', :label => 'Timezone name', :allow_change => true, :select_from => lambda { ActiveSupport::TimeZone::MAPPING.keys.sort }
end 

Radiant.config do |config|
  config.define 'admin.title', :default => "Radiant CMS"
  config.define 'dev.host'
  config.define 'local.timezone', :allow_change => true, :select_from => lambda { ActiveSupport::TimeZone::MAPPING.keys.sort }
  config.define 'defaults.locale', :select_from => lambda { Radiant::AvailableLocales.locales }, :allow_blank => true
  config.define 'defaults.page.parts', :default => "Body,Extended"
  config.define 'defaults.page.status', :select_from => lambda { Status.selectable_values }, :allow_blank => true, :default => "Draft"
  config.define 'defaults.page.filter', :select_from => lambda { TextFilter.descendants.map { |s| s.filter_name }.sort }, :allow_blank => true
  config.define 'defaults.page.fields'
  config.define 'pagination.param_name', :default => 'page'
  config.define 'pagination.per_page_param_name', :default => 'per_page'
  config.define 'admin.pagination.per_page', :type => :integer, :default => 50
  config.define 'site.title'
  config.define 'site.domain'
  config.define 'user.allow_password_reset?', :default => true
end 

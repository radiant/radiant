class ConfigDataset < Dataset::Base
  def load
    # Simulates the defaults on bootstrapped Radiant instances
    Radiant::Config['admin.title'] = 'Radiant CMS' 
    Radiant::Config['admin.subtitle'] = 'Publishing for Small Teams'
    Radiant::Config['defaults.page.parts'] = 'body, extended'
    Radiant::Config['defaults.page.status'] = 'draft'
    Radiant::Config['defaults.page.filter'] = nil
    Radiant::Config['session_timeout'] = 2.weeks
  end
end
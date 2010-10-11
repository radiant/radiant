Radiant::Config.prepare do |config|
  config.namespace('testing', :allow_change => true) do |testing|
    testing.define 'defaulted', :label => 'Has a default', :default => "this default string"
    testing.define 'protected', :label => 'Cannot change', :default => "something", :allow_change => false
    testing.define 'validated', :label => 'Has validation', :default => "monkey", :validate_with => lambda {|s| s.errors.add(:value, "not monkey") unless s.value == "monkey" }
    testing.define 'selected', :select_from => lambda { TextFilter.descendants.map { |s| s.filter_name }.sort }, :label => "Default text filter", :allow_blank => true
  end
end 

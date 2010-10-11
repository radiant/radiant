Radiant::Config.prepare do |config|
  config.namespace('testing', :allow_change => true) do |testing|
    testing.define 'invalid', :label => 'Default is not valid', :default => "non-monkey", :validate_with => lambda {|s| s.errors.add(:value, "non-monkey!") unless s.value == "monkey" }
  end
end 

Radiant::Config.prepare do |config|
  config.namespace('testing', :allow_change => true) do |testing|
    testing.define 'simple', :label => 'A text setting', :notes => 'just a string', :default => "this string"
  end
end 

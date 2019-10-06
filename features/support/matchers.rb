Dir.glob("#{RADIANT_ROOT}/spec/matchers/*.rb").each do |matcher|
  require matcher
end
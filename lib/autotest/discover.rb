Autotest.add_discovery do
  "radiant" if File.exists?(File.join('bin', 'radiant'))
end
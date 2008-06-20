class String
  
  # Convert a string into the associated scenario class:
  #
  #   "basic".to_scenario #=> BasicScenario
  #   "basic_scenario".to_scenario #=> BasicScenario
  #
  # Raises Scenario::NameError if the the scenario cannot be loacated in
  # Scenario.load_paths.
  def to_scenario
    class_name = "#{self.strip.camelize.sub(/Scenario$/, '')}Scenario"
    Scenario.load_paths.each do |path|
      filename = "#{path}/#{class_name.underscore}.rb"
      if File.file?(filename)
        require filename
        break
      end
    end
    class_name.constantize rescue raise Scenario::NameError, "Expected to find #{class_name} in #{Scenario.load_paths.inspect}"
  end
  
end
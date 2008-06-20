class Symbol
  
  # Convert a symbol into the associated scenario class:
  #
  #   :basic.to_scenario #=> BasicScenario
  #   :basic_scenario.to_scenario #=> BasicScenario
  #
  # Raises Scenario::NameError if the the scenario cannot be located in
  # Scenario.load_paths.
  def to_scenario
    to_s.to_scenario
  end
  
end
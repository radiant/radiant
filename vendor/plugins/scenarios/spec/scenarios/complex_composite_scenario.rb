class ComplexCompositeScenario < Scenario::Base
  uses :composite, :places
  
  helpers do
    def method_from_complex_composite_scenario
      :method_from_complex_composite_scenario
    end
  end
end
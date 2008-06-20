class CompositeScenario < Scenario::Base
  uses :people, :things
  
  helpers do
    def method_from_composite_scenario
      :method_from_composite_scenario
    end
  end
end
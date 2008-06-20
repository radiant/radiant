namespace :db do
  namespace :scenario do
    desc "Load a scenario into the current environment's database using SCENARIO=scenario_name"
    task :load => ['environment', 'db:reset'] do
      require 'scenarios'
      scenario_name = ENV['SCENARIO'] || 'default'
      begin
        klass = Scenarios.load(scenario_name)
      rescue Scenarios::NameError => e
        if scenario_name == 'default'
          puts "Error! Set the SCENARIO environment variable or define a DefaultScenario class."
        else
          puts "Error! Invalid scenario name [#{scenario_name}]."
        end
        exit(1)
      else
        puts "Loaded #{klass.name.underscore.gsub('_', ' ')}."
      end
    end
  end
end
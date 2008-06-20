require File.expand_path(File.dirname(__FILE__) + "/test_helper")

raise "RSpec should not have been loaded" if defined?(Spec)

class ScenariosTest < Test::Unit::TestCase
  def setup
    @test_result = Test::Unit::TestResult.new

    tracking_scenario = @tracking_scenario = Class.new((:things).to_scenario) do
      cattr_accessor :instance
      def initialize(*args)
        raise "Should only be created once" if self.class.instance
        self.class.instance = super(*args)
      end
    end
    @test_case = Class.new(Test::Unit::TestCase) do
      scenario tracking_scenario
      def test_something; end
      def test_bad_stuff
        raise "bad stuff"
      end
    end
  end
  
  def test_should_unload_scenario_at_end_of_run
    @test_case.suite.run(@test_result) {}
    assert @tracking_scenario.instance.unloaded?
  end
  
  def test_should_give_the_test_all_the_helper_methods
    assert @test_case.instance_methods.include?("create_record")
  end
  
  def test_should_load_scenarios_on_setup_and_install_helpers
    test = @test_case.new("test_something")
    assert_nothing_raised { test.run(@test_result) {|state,name|} }
    assert !test.things(:one).nil?
  end
end
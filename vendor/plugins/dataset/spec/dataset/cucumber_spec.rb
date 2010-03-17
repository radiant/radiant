require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

$:.unshift(File.dirname(__FILE__) + '/../stubs')
require "mini_rails"

require 'cucumber/rails/world'
require 'cucumber/rails/rspec'
Cucumber::Rails::World.class_eval do
  include Dataset
end

describe Cucumber::Rails::World do
  
  it 'should have a dataset method' do
    world = Class.new(Cucumber::Rails::World)
    world.should respond_to(:dataset)
  end
  
  it 'should load the dataset when the feature is run' do
    load_count = 0
    my_dataset = Class.new(Dataset::Base) do
      define_method(:load) do
        load_count += 1
      end
    end
    
    step_mother = Object.new
    step_mother.extend(Cucumber::StepMother)
    $__cucumber_toplevel = step_mother
    step_mother.World do |world|
      world = Cucumber::Rails::World.new
      world.class.dataset(my_dataset)
      world
    end
    step_mother.Given /true is true/ do |n|
      true.should == true
    end
    visitor = Cucumber::Ast::Visitor.new(step_mother)
    
    scenario = Cucumber::Ast::Scenario.new(
      background=nil,
      comment=Cucumber::Ast::Comment.new(""),
      tags=Cucumber::Ast::Tags.new(98, []), 
      line=99,
      keyword="",
      name="", 
      steps=[
        Cucumber::Ast::Step.new(8, "Given", "true is true")
      ])
    visitor.visit_feature_element(scenario)
    
    load_count.should be(1)
  end
end
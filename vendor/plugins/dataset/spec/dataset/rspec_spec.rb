require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

class Spec::Example::ExampleGroup
  include Dataset
end

describe Spec::Example::ExampleGroup do
  with_sandboxed_options do
    it 'should have a dataset method' do
      group = Class.new(Spec::Example::ExampleGroup)
      group.should respond_to(:dataset)
    end
    
    it 'should load the dataset when the group is run' do
      load_count = 0
      dataset = Class.new(Dataset::Base) do
        define_method(:load) do
          load_count += 1
        end
      end
      
      group = Class.new(Spec::Example::ExampleGroup) do
        self.dataset(dataset)
        it('one') {}
        it('two') {}
      end
      
      group.run options
      load_count.should be(1)
    end
    
    it 'should load datasets in nested groups' do
      dataset_one = Class.new(Dataset::Base) do
        define_method(:load) do
          Thing.create!
        end
      end
      dataset_two = Class.new(Dataset::Base) do
        define_method(:load) do
          Place.create!
        end
      end
      
      group = Class.new(Spec::Example::ExampleGroup) do
        dataset(dataset_one)
        it('one') {}
      end
      group_child = Class.new(group) do
        dataset(dataset_two)
        it('two') {}
      end
      
      group.run options
      Thing.count.should be(1)
      Place.count.should be(0)
      
      group_child.run options
      Thing.count.should be(1)
      Place.count.should be(1)
    end
    
    it 'should expose data reading methods from dataset binding to the test methods through the group instances' do
      created_model = nil
      dataset = Class.new(Dataset::Base) do
        define_method(:load) do
          created_model = create_model(Thing, :dataset_thing)
        end
      end
      
      found_in_before_all, dataset_thing_in_example = nil
      created_in_before_all, before_all_thing_in_example = nil
      created_in_example = nil
      group = Class.new(Spec::Example::ExampleGroup) do
        self.dataset(dataset)
        before(:all) do
          found_in_before_all = things(:dataset_thing)
          created_in_before_all = create_model(Thing, :before_all_thing)
        end
        it 'one' do
          dataset_thing_in_example = things(:dataset_thing)
          before_all_thing_in_example = things(:before_all_thing)
          created_in_example = create_model(Thing)
        end
      end
      
      group.run options
      group.should_not respond_to(:things)
      
      dataset_thing_in_example.should_not be_nil
      dataset_thing_in_example.should == created_model
      
      found_in_before_all.should_not be_nil
      found_in_before_all.should == created_model
      
      created_in_before_all.should_not be_nil
      before_all_thing_in_example.should == created_in_before_all
      
      created_in_example.should_not be_nil
    end
    
    it 'should expose dataset helper methods to the test methods through the group instances' do
      dataset_one = Class.new(Dataset::Base) do
        helpers do
          def helper_one; end
        end
        def load; end
      end
      dataset_two = Class.new(Dataset::Base) do
        uses dataset_one
        helpers do
          def helper_two; end
        end
        def load; end
      end
      
      group = Class.new(Spec::Example::ExampleGroup) do
        self.dataset(dataset_two)
        before(:all) do
          self.should respond_to(:helper_one)
          self.should respond_to(:helper_two)
        end
        it 'one' do
          self.should respond_to(:helper_one)
          self.should respond_to(:helper_two)
        end
      end
      
      group.run options
      group.should_not respond_to(:helper_one)
      group.should_not respond_to(:helper_two)
    end
  end
end
require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

require 'test/unit/testresult'
class Test::Unit::TestCase
  include Dataset
end

describe Test::Unit::TestCase do
  it 'should have a dataset method' do
    testcase = Class.new(Test::Unit::TestCase)
    testcase.should respond_to(:dataset)
  end
  
  it 'should accept multiple datasets' do
    load_count = 0
    dataset_one = Class.new(Dataset::Base) do
      define_method(:load) { load_count += 1 }
    end
    dataset_two = Class.new(Dataset::Base) do
      define_method(:load) { load_count += 1 }
    end
    testcase = Class.new(Test::Unit::TestCase) do
      dataset dataset_one, dataset_two
    end
    run_testcase(testcase)
    load_count.should be(2)
  end
  
  it 'should provide one dataset session for tests' do
    sessions = []
    testcase = Class.new(Test::Unit::TestCase) do
      dataset Class.new(Dataset::Base)
      
      define_method(:test_one) do
        sessions << dataset_session
      end
      define_method(:test_two) do
        sessions << dataset_session
      end
    end
    run_testcase(testcase)
    sessions.size.should be(2)
    sessions.uniq.size.should be(1)
  end
  
  it 'should load datasets within class hiearchy' do
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
    
    testcase = Class.new(Test::Unit::TestCase) do
      dataset(dataset_one)
      def test_one; end
    end
    testcase_child = Class.new(testcase) do
      dataset(dataset_two)
      def test_two; end
    end
    
    run_testcase(testcase)
    Thing.count.should be(1)
    Place.count.should be(0)
    
    run_testcase(testcase_child)
    Thing.count.should be(1)
    Place.count.should be(1)
  end
  
  it 'should forward blocks passed in to the dataset method' do
    load_count = 0
    testcase = Class.new(Test::Unit::TestCase) do
      dataset_class = Class.new(Dataset::Base)
      dataset dataset_class do
        load_count += 1
      end
    end
    
    run_testcase(testcase)
    load_count.should == 1
  end
  
  it 'should forward blocks passed in to the dataset method that do not use a dataset class' do
    load_count = 0
    testcase = Class.new(Test::Unit::TestCase) do
      dataset do
        load_count += 1
      end
    end
    
    run_testcase(testcase)
    load_count.should == 1
  end
  
  it 'should copy instance variables from block to tests' do
    value_in_test = nil
    testcase = Class.new(Test::Unit::TestCase) do
      dataset do
        @myvar = 'Hello'
      end
      define_method :test_something do
        value_in_test = @myvar
      end
    end
    
    run_testcase(testcase)
    value_in_test.should == 'Hello'
  end
  
  it 'should copy instance variables from block to subclass blocks' do
    value_in_subclass_block = nil
    testcase = Class.new(Test::Unit::TestCase) do
      dataset do
        @myvar = 'Hello'
      end
    end
    subclass = Class.new(testcase) do
      dataset do
        value_in_subclass_block = @myvar
      end
    end
    
    run_testcase(subclass)
    value_in_subclass_block.should == 'Hello'
  end
  
  it 'should load the dataset when the suite is run' do
    load_count = 0
    dataset = Class.new(Dataset::Base) do
      define_method(:load) do
        load_count += 1
      end
    end
    
    testcase = Class.new(Test::Unit::TestCase) do
      self.dataset(dataset)
      def test_one; end
      def test_two; end
    end
    
    run_testcase(testcase)
    load_count.should be(1)
  end
  
  it 'should expose data reading methods from dataset binding to the test methods through the test instances' do
    created_model, found_model = nil
    dataset = Class.new(Dataset::Base) do
      define_method(:load) do
        created_model = create_model(Thing, :mything)
      end
    end
    
    testcase = Class.new(Test::Unit::TestCase) do
      self.dataset(dataset)
      define_method :test_model_finders do
        found_model = things(:mything)
      end
    end
    
    run_testcase(testcase)
    testcase.should_not respond_to(:things)
    found_model.should_not be_nil
    found_model.should == created_model
  end
  
  it 'should expose dataset helper methods to the test methods through the test instances' do
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
    
    test_instance = nil
    testcase = Class.new(Test::Unit::TestCase) do
      self.dataset(dataset_two)
      define_method :test_model_finders do
        test_instance = self
      end
    end
    
    run_testcase(testcase)
    
    testcase.should_not respond_to(:helper_one)
    testcase.should_not respond_to(:helper_two)
    test_instance.should respond_to(:helper_one)
    test_instance.should respond_to(:helper_two)
  end
  
  def run_testcase(testcase)
    result = Test::Unit::TestResult.new
    testcase.module_eval { def test_dont_complain; end }
    testcase.suite.run(result) {}
    result.failure_count.should be(0)
    result.error_count.should be(0)
  end
end
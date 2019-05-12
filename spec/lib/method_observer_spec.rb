require File.dirname(__FILE__) + "/../spec_helper"

describe MethodObserver do
  
  class TestObserver < MethodObserver    
    def before_observed_method(*args, &block); end
    def after_observed_method(*args); end
  end

  class TestObject
    def observed_method
      :success
    end
  end

  before :each do
    @object = TestObject.new
    @object.stub!(:before_result=).and_return(nil)
    @object.stub!(:after_result=).and_return(:success)
    @observer = TestObserver.new
    @observer.observe(@object)
  end
  
  it "should permit only one object to be observed" do
    lambda { @observer.observe(@object)}.should raise_error(MethodObserver::ObserverCannotObserveTwiceError)
  end
  
  it "should have a target equal to the observed object" do
    @observer.should respond_to(:target)
    @observer.target.should == @object
  end
  
  it "should invoke the before_ method before the object's method is invoked" do
    @observer.should_receive(:before_observed_method) do
      @observer.result.should be_nil
    end
    @object.observed_method.should == :success
    @observer.result.should == :success
  end
  
  it "should invoke the after_ method after the object's method is invoked" do
    @observer.should_receive(:after_observed_method) do
      @observer.result.should == :success
    end
    @object.observed_method.should == :success
    @observer.result.should == :success
  end
end

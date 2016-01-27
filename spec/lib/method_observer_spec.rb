require "spec_helper"
require 'method_observer'

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
    allow(@object).to receive(:before_result=).and_return(nil)
    allow(@object).to receive(:after_result=).and_return(:success)
    @observer = TestObserver.new
    @observer.observe(@object)
  end

  it "should permit only one object to be observed" do
    expect { @observer.observe(@object)}.to raise_error(MethodObserver::ObserverCannotObserveTwiceError)
  end

  it "should have a target equal to the observed object" do
    expect(@observer).to respond_to(:target)
    expect(@observer.target).to eq(@object)
  end

  it "should invoke the before_ method before the object's method is invoked" do
    expect(@observer).to receive(:before_observed_method) do
      expect(@observer.result).to be_nil
    end
    expect(@object.observed_method).to eq(:success)
    expect(@observer.result).to eq(:success)
  end

  it "should invoke the after_ method after the object's method is invoked" do
    expect(@observer).to receive(:after_observed_method) do
      expect(@observer.result).to eq(:success)
    end
    expect(@object.observed_method).to eq(:success)
    expect(@observer.result).to eq(:success)
  end
end

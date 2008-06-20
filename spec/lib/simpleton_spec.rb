require File.dirname(__FILE__) + "/../spec_helper"

class Dumbo
  include Simpleton
end

describe Simpleton, "when included in a class" do
 
  it "should add an 'instance' class method" do
    Dumbo.should respond_to(:instance)
  end
  
end

describe Simpleton, "when creating or invoking the instance" do

  before :each do
    Dumbo.class_eval { @instance = nil }
  end

  it "should return the instance of the class" do
    Dumbo.instance.should be_instance_of(Dumbo)
  end
  
  it "should accept a block and yield the instance" do
    Dumbo.instance do |i|
      i.should be_instance_of(Dumbo)
      i.should == Dumbo.class_eval { @instance }
    end
  end
  
end

describe Simpleton, "when invoking methods" do

  it "should delegate missing class methods to the instance" do
    Dumbo.class_eval { def an_instance_method; :success; end }
    Dumbo.an_instance_method.should == :success
  end
  
  it "should not delegate missing class methods that are not defined on the instance" do
    lambda { Dumbo.missing_instance_method }.should raise_error(NoMethodError)
  end
  
end

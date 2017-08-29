require File.dirname(__FILE__) + "/../spec_helper"

class Dumbo
  include Simpleton
end

describe Simpleton, "when included in a class" do
 
  it "should add an 'instance' class method" do
    expect(Dumbo).to respond_to(:instance)
  end
  
end

describe Simpleton, "when creating or invoking the instance" do

  before :each do
    Dumbo.class_eval { @instance = nil }
  end

  it "should return the instance of the class" do
    expect(Dumbo.instance).to be_instance_of(Dumbo)
  end
  
  it "should accept a block and yield the instance" do
    Dumbo.instance do |i|
      expect(i).to be_instance_of(Dumbo)
      expect(i).to eq(Dumbo.class_eval { @instance })
    end
  end
  
end

describe Simpleton, "when invoking methods" do

  it "should delegate missing class methods to the instance" do
    Dumbo.class_eval { def an_instance_method; :success; end }
    expect(Dumbo.an_instance_method).to eq(:success)
  end
  
  it "should not delegate missing class methods that are not defined on the instance" do
    expect { Dumbo.missing_instance_method }.to raise_error(NoMethodError)
  end
  
end

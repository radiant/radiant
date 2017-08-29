require File.dirname(__FILE__) + "/../spec_helper"

describe Annotatable, "when included in a class" do
  class BasicAnnotation
    include Annotatable
  end

  it "should add the annotate method to a class" do
    expect(BasicAnnotation).to respond_to(:annotate)
  end
end

describe Annotatable, "with an annotation added to a class" do
  class AnnotationsAdded
    include Annotatable
    annotate :description
  end

  it "should add class accessor methods of the given name for the annotation" do
    expect(AnnotationsAdded).to respond_to(:description)
    expect(AnnotationsAdded).to respond_to(:description=)
  end

  it "should add instance accessor methods of the given name for the annotation" do
    @a = AnnotationsAdded.new
    expect(@a).to respond_to(:description)
    expect(@a).to respond_to(:description=)
  end
  
  it "should set the value of the annotation when called with a parameter" do
    AnnotationsAdded.description "test"
    expect(AnnotationsAdded.description).to eq("test")
  end
  
  it "should set the value of the annotation when assigned directly" do
    AnnotationsAdded.description = "test"
    expect(AnnotationsAdded.description).to eq("test")    
  end
  
  it "should set the value of the annotation when called with a parameter on an instance" do
    AnnotationsAdded.new.description "test"
    expect(AnnotationsAdded.description).to eq("test")
  end
  
  it "should set the value of the annotation when assigned directly on an instance" do
    AnnotationsAdded.new.description = "test"
    expect(AnnotationsAdded.description).to eq("test")    
  end
end

describe Annotatable, "with annotations defined on a parent class" do
  class ParentClass
    include Annotatable
    annotate :description, :url
    annotate :another, inherit: true
    description "A parent class"
    url "http://test.host"
    another "I'm inherited!"
  end

  class ChildClass < ParentClass
  end

  class OverridingClass < ParentClass
    another "I'm not inherited!"
  end
  
  it "should receive all parent annotations" do
    [:description, :url, :another].each do |method|
      expect(ChildClass).to respond_to(method)
    end
  end
  
  it "should inherit the parent class' values for inherit annotations" do
    expect(ChildClass.another).to eq("I'm inherited!")
  end
  
  it "should not inherit values for non-inherited annotations" do
    expect(ChildClass.description).to be_nil
    expect(ChildClass.url).to be_nil
  end
  
  it "should override inherited values when annotated in a child class" do
    expect(OverridingClass.another).to eq("I'm not inherited!")
  end
end

require File.dirname(__FILE__) + "/../spec_helper"

describe InheritableClassAttributes, "when included in a class" do
  class BasicInheritable
    include InheritableClassAttributes
    cattr_inheritable_accessor :accessor
  end
  
  it "should add inheritable attribute declaration methods to the class" do
    BasicInheritable.should respond_to(:cattr_inheritable_reader)
    BasicInheritable.should respond_to(:cattr_inheritable_writer)
    BasicInheritable.should respond_to(:cattr_inheritable_accessor)
  end
  
  it "should allow child classes to override the value without affecting the parent" do
    BasicInheritable.accessor = :unchanged
    Kernel.module_eval { class AnotherAccessor < BasicInheritable; end}
    AnotherAccessor.accessor = :changed
    BasicInheritable.accessor.should == :unchanged
    AnotherAccessor.accessor.should == :changed
  end
  
  it "should copy the attribute value to child classes when subclassed" do
    BasicInheritable.accessor = :unchanged
    Kernel.module_eval { class AccessorInherited < BasicInheritable; end}
    AccessorInherited.accessor.should == :unchanged
  end
end

describe InheritableClassAttributes, "when a reader is defined on a class" do
  class WithInheritableReader
    include InheritableClassAttributes
    cattr_inheritable_reader :reader
    @reader = "testing!"
  end
    
  it "should create a reader method on the class for the attribute" do
    WithInheritableReader.should respond_to(:reader)
    WithInheritableReader.should_not respond_to(:reader=)
  end
  
  it "should return the value of the corresponding class instance variable" do
    WithInheritableReader.reader.should == "testing!"
  end
  
  it "should pass the reader down to its child classes" do
    Kernel.module_eval { class ReaderInherited < WithInheritableReader; end }
    ReaderInherited.should respond_to(:reader)
  end
end

describe InheritableClassAttributes, "when a writer is defined on a class" do
  class WithInheritableWriter
    include InheritableClassAttributes
    cattr_inheritable_writer :writer
  end

  it "should create a writer method on the class for the attribute" do
    WithInheritableWriter.should respond_to(:writer=)
    WithInheritableWriter.should_not respond_to(:writer)
  end
  
  it "should assign the value of the corresponding class instance variable"  do
    WithInheritableWriter.writer = :writer
    WithInheritableWriter.instance_variable_get("@writer").should == :writer
  end
  
  it "should pass the writer down to its child classes" do
    Kernel.module_eval { class WriterInherited < WithInheritableWriter;  end }
    WriterInherited.should respond_to(:writer=)
  end  
end

describe InheritableClassAttributes, "when an accessor is defined on a class" do
  class WithInheritableAccessor
    include InheritableClassAttributes
    cattr_inheritable_accessor :accessor
  end
  
  it "should create reader and writer methods on the class for the attribute" do
    WithInheritableAccessor.should respond_to(:accessor)
    WithInheritableAccessor.should respond_to(:accessor=)
  end
  
  it "should pass the writer and reader down to its child classes" do
    Kernel.module_eval { class Accessor < WithInheritableAccessor; end }
    Accessor.should respond_to(:accessor)
    Accessor.should respond_to(:accessor=)
  end
end

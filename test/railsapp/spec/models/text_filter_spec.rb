require File.dirname(__FILE__) + '/../spec_helper'

describe TextFilter do
  class ReverseFilter < TextFilter
    description %{Reverses text.}
    def filter(text)
      text.reverse
    end
  end

  class CustomFilter < TextFilter
    filter_name "Really Custom"
    description_file File.dirname(__FILE__) + "/../fixtures/sample.txt"
  end

  it 'should allow description annotation' do
    ReverseFilter.description.should == %{Reverses text.}
  end
  
  it 'should allow description_file annotation' do
    CustomFilter.description.should == File.read(File.dirname(__FILE__) + "/../fixtures/sample.txt")
  end

  it 'should return an array of filter_names of all available filters' do
    TextFilter.descendants_names.should include("Markdown", "Really Custom", "Reverse", "SmartyPants", "Textile")
  end

  it 'should filter text with base filter' do
    filter = TextFilter.new
    filter.filter('test').should == 'test'
  end
  
  it 'should filter text with subclass' do
    ReverseFilter.filter('test').should == 'tset'
  end
  
  it 'should allow filter_name annotation' do
    CustomFilter.filter_name.should == 'Really Custom'
  end
  
  it 'should default filter_name annotation' do
    ReverseFilter.filter_name.should == 'Reverse'
  end
end

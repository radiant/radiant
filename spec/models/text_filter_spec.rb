require 'spec_helper'

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

describe TextFilter do
  it 'should allow description annotation' do
    expect(ReverseFilter.description).to eq(%{Reverses text.})
  end

  it 'should allow description_file annotation' do
    expect(CustomFilter.description).to eq(File.read(File.dirname(__FILE__) + "/../fixtures/sample.txt"))
  end

  it 'should return an array of filter_names of all available filters' do
    expect(TextFilter.descendants_names).to include("Really Custom", "Reverse")
  end

  it 'should filter text with base filter' do
    filter = TextFilter.new
    expect(filter.filter('test')).to eq('test')
  end

  it 'should filter text with subclass' do
    expect(ReverseFilter.filter('test')).to eq('tset')
  end

  it 'should allow filter_name annotation' do
    expect(CustomFilter.filter_name).to eq('Really Custom')
  end

  it 'should default filter_name annotation' do
    expect(ReverseFilter.filter_name).to eq('Reverse')
  end
end

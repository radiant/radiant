require File.dirname(__FILE__) + '/../spec_helper'

describe Snippet do
  dataset :snippets
  test_helper :validations
  
  before :each do
    @original_filter = Radiant::Config['defaults.snippet.filter']
    @snippet = @model = Snippet.new(snippet_params)
  end

  after :each do
    Radiant::Config['defaults.snippet.filter'] = @original_filter
  end

  it "should take the filter from the default filter" do
    Radiant::Config['defaults.snippet.filter'] = "Textile"
    snippet = Snippet.new :name => 'new-snippet'
    snippet.filter_id.should == "Textile"
  end

  it "shouldn't override existing snippets filters with the default filter" do
    snippet = Snippet.find(:first, :conditions => {:filter_id => nil})
    Radiant::Config['defaults.snippet.filter'] = "Textile"
    snippet.reload
    snippet.filter_id.should_not == "Textile"
  end
  
  it 'should validate length of' do
    {
      :name => 100,
      :filter_id => 25
    }.each do |field, max|
      assert_invalid field, ('this must not be longer than %d characters' % max), 'x' * (max + 1)
      assert_valid field, 'x' * max
    end
  end
  
  it 'should validate presence of' do
    [:name].each do |field|
      assert_invalid field, 'this must not be blank', '', ' ', nil
    end
  end
  
  it 'should validate uniqueness of' do
    assert_invalid :name, 'this name is already in use', 'first', 'another', 'markdown'
    assert_valid :name, 'just-a-test'
  end
  
  it 'should validate format of name' do
    assert_valid :name, 'abc', 'abcd-efg', 'abcd_efg', 'abc.html', '/', '123'
    assert_invalid :name, 'cannot contain spaces or tabs'
  end
  
  it 'should allow the filter to be specified' do
    @snippet = snippets(:markdown)
    @snippet.filter.should be_kind_of(MarkdownFilter)
  end
end

require File.dirname(__FILE__) + "/../../spec_helper"
require 'ostruct'

describe Radiant::Taggable, "when included in a class or module" do

  class TaggedClass
    include Radiant::Taggable
  end
  
  module TaggedModule
    include Radiant::Taggable
  end
  
  it "should add tag definition methods to the class" do
    [TaggedClass, TaggedModule].each do |c|
      c.should respond_to(:tag)
      c.should respond_to(:desc)
    end
  end
  
  it "should turn tag definitions into methods" do
    [TaggedClass, TaggedModule].each do |c|
      c.tag 'hello' do 
        "hello world" 
      end
      c.instance_methods.should include("tag:hello")
    end
    TaggedClass.new.send("tag:hello").should == "hello world"
  end
  
  it "should store tag descriptions filtered with Textile" do
    [TaggedClass, TaggedModule].each do |c|
      c.desc "A simple tag."
      Radiant::Taggable.last_description.should == "<p>A simple tag.</p>"
    end
  end
  
  it "should associate a tag description with the tag definition that follows it" do
    [TaggedClass, TaggedModule].each do |c|
      c.desc "Bonjour!"
      c.tag "hello" do
        "hello world"
      end
      c.tag_descriptions['hello'].should =~ /Bonjour!/
      Radiant::Taggable.last_description.should be_nil
    end
  end
  
  it "should normalize leading whitespace in a tag description" do
    Radiant::Taggable::Util.should_receive(:strip_leading_whitespace).twice.with("   Blah blah\n blah blah").and_return("blah")
    [TaggedClass, TaggedModule].each do |c|
      c.desc "   Blah blah\n blah blah"
    end
  end
end

describe Radiant::Taggable, "when included in a module with defined tags" do

  module MyTags
    include Radiant::Taggable
    
    desc %{This tag renders the text "just a test".}
    tag "test" do
      "just a test"
    end

    desc %{This tag implements "Hello, world!".}    
    tag "hello" do |tag|
      "Hello, #{ tag.attr['name'] || 'world' }!"
    end
    
    tag "page_index_path" do |tag|
      admin_pages_path
    end
  end

  class TestObject
    include Radiant::Taggable
    
    desc %{Yet another test}
    tag "test" do
      "My new test"
    end
    
    include MyTags
  end

  before :each do
    @object = TestObject.new
    @tag_binding = OpenStruct.new('attr' => {"name" => "John"})
  end

  it "should have a collection of defined tags" do
    MyTags.should respond_to(:tags)
    MyTags.tags.should == ['hello', 'page_index_path', 'test']
  end
  
  it "should add tags to an included class" do
    TestObject.should respond_to(:tags)
    TestObject.tags.should == ['hello', 'page_index_path', 'test']
  end
  
  it "should merge tag descriptions with an included class" do
    TestObject.tag_descriptions["test"].should == MyTags.tag_descriptions["test"]
  end
  
  it "should render a defined tag on an instance of an included class" do
    @object.should respond_to(:render_tag)
    @object.render_tag(:test, {}).should == "My new test"
  end

  it "should render a defined tag on an instance of an included class with a given tag binding" do
    @object.render_tag(:hello, @tag_binding).should == "Hello, John!"
  end
  
  it "should render a url helper called in a tag definition" do
    @object.render_tag(:page_index_path, {}).should == "/admin/pages"
  end

end

describe Radiant::Taggable, "when included in a module with defined tags which is included in the Page model" do
  scenario :users_and_pages, :file_not_found, :snippets
  
  module CustomTags
    include Radiant::Taggable
    
    tag "param_value" do |tag|
      params[:sample_param]
    end
  end
  
  Page.send :include, CustomTags
  
  it 'should render a param value used in a tag' do
    page(:home)
    page.should render('<r:param_value />').as('data')
  end
  
  private
    def page(symbol = nil)
      if symbol.nil?
        @page ||= pages(:assorted)
      else
        @page = pages(symbol)
      end
    end
end

describe Radiant::Taggable::Util do
  it "should normalize leading whitespace" do
        markup = %{  
  
  I'm a really small paragraph that
  happens to span two lines.
  
  * I'm just
  * a simple
  * list

  Let's try a small code example:
  
    puts "Hello world!"
  
  Nice job! It really, really, really
  works.

}
result = %{

I'm a really small paragraph that
happens to span two lines.

* I'm just
* a simple
* list

Let's try a small code example:

  puts "Hello world!"

Nice job! It really, really, really
works.}
    Radiant::Taggable::Util.strip_leading_whitespace(markup).should == result
  end
end

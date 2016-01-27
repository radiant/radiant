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
      expect(c).to respond_to(:tag)
      expect(c).to respond_to(:desc)
    end
  end

  it "should turn tag definitions into methods" do
    [TaggedClass, TaggedModule].each do |c|
      c.tag 'hello' do
        "hello world"
      end
      expect(c.instance_methods.collect {|im| im.to_s}).to include("tag:hello")
    end
    expect(TaggedClass.new.send("tag:hello")).to eq("hello world")
  end

  it "should store tag descriptions filtered without Textile, so that translations can be applied" do
    [TaggedClass, TaggedModule].each do |c|
      c.desc "A simple tag."
      expect(Radiant::Taggable.last_description).to eq("A simple tag.")
    end
  end

  it "should associate a tag description with the tag definition that follows it" do
    [TaggedClass, TaggedModule].each do |c|
      c.desc "Bonjour!"
      c.tag "hello" do
        "hello world"
      end
      expect(c.tag_descriptions['hello']).to match(/Bonjour!/)
      expect(Radiant::Taggable.last_description).to be_nil
    end
  end

  # This has been moved to the admin/references_helper
  #
  # it "should normalize leading whitespace in a tag description" do
  #   Radiant::Taggable::Util.should_receive(:strip_leading_whitespace).twice.with("   Blah blah\n blah blah").and_return("blah")
  #   [TaggedClass, TaggedModule].each do |c|
  #     c.desc "   Blah blah\n blah blah"
  #   end
  # end
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
    expect(MyTags).to respond_to(:tags)
    expect(MyTags.tags).to eq(['hello', 'page_index_path', 'test'])
  end

  it "should add tags to an included class" do
    expect(TestObject).to respond_to(:tags)
    expect(TestObject.tags).to eq(['hello', 'page_index_path', 'test'])
  end

  it "should merge tag descriptions with an included class" do
    expect(TestObject.tag_descriptions["test"]).to eq(MyTags.tag_descriptions["test"])
  end

  it "should render a defined tag on an instance of an included class" do
    expect(@object).to respond_to(:render_tag)
    expect(@object.render_tag(:test, {})).to eq("My new test")
  end

  it "should render a defined tag on an instance of an included class with a given tag binding" do
    expect(@object.render_tag(:hello, @tag_binding)).to eq("Hello, John!")
  end

  it "should render a url helper called in a tag definition" do
    expect(@object.render_tag(:page_index_path, {})).to eq("/admin/pages")
  end

end

describe Radiant::Taggable, "when included in a module with defined tags which is included in the Page model" do
  #dataset :users_and_pages, :file_not_found

  module CustomTags
    include Radiant::Taggable

    tag "param_value" do |tag|
      params[:sample_param]
    end
  end

  Page.send :include, CustomTags

  it 'should render a param value used in a tag' do
    page(:home)
    expect(page).to render('<r:param_value />').as('data')
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

describe Radiant::Taggable, "when included in a module with deprecated tags" do

  class OldTestObject
    include Radiant::Taggable

    desc %{This is an exciting new tag}
    tag "new_hotness" do "Dreadful film."; end

    desc %{This tag is deprecated but still renders the text "just an old test".}
    deprecated_tag "old_testy" do "just an old test"; end

    desc %{This tag deprecated in favour of the tag 'new_hotness'.}
    deprecated_tag "old_busted", substitute: 'new_hotness', version: '9.0'
  end

  before :each do
    @object = OldTestObject.new
    @tag_binding = double('tag_binding')
    allow(@tag_binding).to receive(:attr).and_return({name: 'testy'})
    allow(@tag_binding).to receive(:block).and_return(nil)
  end

  it "should have a collection of defined tags" do
    expect(OldTestObject).to respond_to(:tags)
    expect(OldTestObject.tags).to match_array(['new_hotness', 'old_testy', 'old_busted'])
  end

  ::ActiveSupport::Deprecation.silence do
    describe 'rendering a deprecated tag with no substitute' do
      it "should warn and render" do
        expect(ActiveSupport::Deprecation).to receive(:warn).and_return(true)
        expect(@object.render_tag(:old_testy, @tag_binding)).to eq("just an old test")
      end
    end

    describe 'rendering a deprecated tag with substitution' do
      it "should warn and substitute" do
        expect(ActiveSupport::Deprecation).to receive(:warn).and_return(true)
        expect(@tag_binding).to receive(:render).with("new_hotness", {name: 'testy'}).and_return("stubbed tag")
        expect(@object.render_tag(:old_busted, @tag_binding)).to eq("stubbed tag")
      end
    end

    describe 'rendering a deprecated tag with an expiry deadline' do
      it "should warn with deadline" do
        expect(ActiveSupport::Deprecation).to receive(:warn) { |*args|
          args.first =~ /will be removed in radiant 9\.0/
        }
        allow(@tag_binding).to receive(:render)
        @object.render_tag(:old_busted, @tag_binding)
      end
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
    expect(Radiant::Taggable::Util.strip_leading_whitespace(markup)).to eq(result)
  end
end

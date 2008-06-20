require 'test/unit'
require 'radius'

module RadiusTestHelper
  class TestContext < Radius::Context; end
  
  def new_context
    Radius::Context.new do |c|
      c.define_tag("reverse"   ) { |tag| tag.expand.reverse }
      c.define_tag("capitalize") { |tag| tag.expand.upcase  }
      c.define_tag("attr"      ) { |tag| tag.attr.inspect   }
      c.define_tag("echo"      ) { |tag| tag.attr['value']  }
      c.define_tag("wrap"      ) { |tag| "[#{tag.expand}]"  }
    end
  end
  
  def define_tag(name, options = {}, &block)
    @context.define_tag name, options, &block
  end
end

class RadiusContextTest < Test::Unit::TestCase
  include RadiusTestHelper
  
  def setup
    @context = new_context
  end
  
  def test_initialize
    @context = Radius::Context.new
  end
  
  def test_initialize_with_block
    @context = Radius::Context.new do |c|
      assert_kind_of Radius::Context, c
      c.define_tag('test') { 'just a test' }
    end
    assert_not_equal Hash.new, @context.definitions
  end
  
  def test_with
    got = @context.with do |c|
      assert_equal @context, c
    end
    assert_equal @context, got
  end
  
  def test_render_tag
    define_tag "hello" do |tag|
      "Hello #{tag.attr['name'] || 'World'}!"
    end
    assert_render_tag_output 'Hello World!', 'hello'
    assert_render_tag_output 'Hello John!', 'hello', 'name' => 'John'
  end
  
  def test_render_tag__undefined_tag
    e = assert_raises(Radius::UndefinedTagError) { @context.render_tag('undefined_tag') }
    assert_equal "undefined tag `undefined_tag'", e.message
  end
  
  def test_tag_missing
    class << @context
      def tag_missing(tag, attr, &block)
        "undefined tag `#{tag}' with attributes #{attr.inspect}"
      end
    end
    
    text = ''
    expected = %{undefined tag `undefined_tag' with attributes {"cool"=>"beans"}}
    assert_nothing_raised { text = @context.render_tag('undefined_tag', 'cool' => 'beans') }
    assert_equal expected, text
  end
  
  private
    
    def assert_render_tag_output(output, *render_tag_params)
      assert_equal output, @context.render_tag(*render_tag_params)
    end
  
end

class RadiusParserTest < Test::Unit::TestCase
  include RadiusTestHelper
  
  def setup
    @context = new_context
    @parser = Radius::Parser.new(@context, :tag_prefix => 'r')
  end
  
  def test_initialize
    @parser = Radius::Parser.new
    assert_kind_of Radius::Context, @parser.context
  end
  
  def test_initialize_with_params
    @parser = Radius::Parser.new(TestContext.new)
    assert_kind_of TestContext, @parser.context
    
    @parser = Radius::Parser.new(:context => TestContext.new)
    assert_kind_of TestContext, @parser.context
    
    @parser = Radius::Parser.new('context' => TestContext.new)
    assert_kind_of TestContext, @parser.context
    
    @parser = Radius::Parser.new(:tag_prefix => 'r')
    assert_kind_of Radius::Context, @parser.context
    assert_equal 'r', @parser.tag_prefix
    
    @parser = Radius::Parser.new(TestContext.new, :tag_prefix => 'r')
    assert_kind_of TestContext, @parser.context
    assert_equal 'r', @parser.tag_prefix
  end
  
  def test_parse_individual_tags_and_parameters
    define_tag "add" do |tag|
      tag.attr["param1"].to_i + tag.attr["param2"].to_i
    end
    assert_parse_output "<3>", %{<<r:add param1="1" param2='2'/>>}
  end
  
  def test_parse_attributes
    attributes = %{{"a"=>"1", "b"=>"2", "c"=>"3", "d"=>"'"}}
    assert_parse_output attributes, %{<r:attr a="1" b='2'c="3"d="'" />}
    assert_parse_output attributes, %{<r:attr a="1" b='2'c="3"d="'"></r:attr>}
  end
  
  def test_parse_attributes_with_slashes_or_angle_brackets
    slash = %{{"slash"=>"/"}}
    angle = %{{"angle"=>">"}}
    assert_parse_output slash, %{<r:attr slash="/"></r:attr>}
    assert_parse_output slash, %{<r:attr slash="/"><r:attr /></r:attr>}
    assert_parse_output angle, %{<r:attr angle=">"></r:attr>}
  end
  
  def test_parse_quotes
    assert_parse_output "test []", %{<r:echo value="test" /> <r:wrap attr="test"></r:wrap>}
  end
  
  def test_things_that_should_be_left_alone
    [
      %{ test="2"="4" },
      %{="2" } 
    ].each do |middle|
      assert_parsed_is_unchanged "<r:attr#{middle}/>"
      assert_parsed_is_unchanged "<r:attr#{middle}>"
    end
  end
    
  def test_parse_result_is_always_a_string
    define_tag("twelve") { 12 }
    assert_parse_output "12", "<r:twelve />"
  end
  
  def test_parse_double_tags
    assert_parse_output "test".reverse, "<r:reverse>test</r:reverse>"
    assert_parse_output "tset TEST", "<r:reverse>test</r:reverse> <r:capitalize>test</r:capitalize>"
  end
  
  def test_parse_tag_nesting
    define_tag("parent", :for => '')
    define_tag("parent:child", :for => '')
    define_tag("extra", :for => '')
    define_tag("nesting") { |tag| tag.nesting }
    define_tag("extra:nesting") { |tag| tag.nesting.gsub(':', ' > ') }
    define_tag("parent:child:nesting") { |tag| tag.nesting.gsub(':', ' * ') }
    assert_parse_output "nesting", "<r:nesting />"
    assert_parse_output "parent:nesting", "<r:parent:nesting />"
    assert_parse_output "extra > nesting", "<r:extra:nesting />"
    assert_parse_output "parent * child * nesting", "<r:parent:child:nesting />"
    assert_parse_output "parent > extra > nesting", "<r:parent:extra:nesting />"
    assert_parse_output "parent > child > extra > nesting", "<r:parent:child:extra:nesting />"
    assert_parse_output "parent * extra * child * nesting", "<r:parent:extra:child:nesting />"
    assert_parse_output "parent > extra > child > extra > nesting", "<r:parent:extra:child:extra:nesting />"
    assert_parse_output "parent > extra > child > extra > nesting", "<r:parent><r:extra><r:child><r:extra><r:nesting /></r:extra></r:child></r:extra></r:parent>"
    assert_parse_output "extra * parent * child * nesting", "<r:extra:parent:child:nesting />"
    assert_parse_output "extra > parent > nesting", "<r:extra><r:parent:nesting /></r:extra>"
    assert_parse_output "extra * parent * child * nesting", "<r:extra:parent><r:child:nesting /></r:extra:parent>"
    assert_raises(Radius::UndefinedTagError) { @parser.parse("<r:child />") }
  end
  def test_parse_tag_nesting_2
    define_tag("parent", :for => '')
    define_tag("parent:child", :for => '')
    define_tag("content") { |tag| tag.nesting }
    assert_parse_output 'parent:child:content', '<r:parent><r:child:content /></r:parent>'
  end
  
  def test_parse_tag__binding_do_missing
    define_tag 'test' do |tag|
      tag.missing!
    end
    e = assert_raises(Radius::UndefinedTagError) { @parser.parse("<r:test />") }
    assert_equal "undefined tag `test'", e.message
  end
  
  def test_parse_tag__binding_render_tag
    define_tag('test') { |tag| "Hello #{tag.attr['name']}!" }
    define_tag('hello') { |tag| tag.render('test', tag.attr) }
    assert_parse_output 'Hello John!', '<r:hello name="John" />'
  end
  def test_parse_tag__binding_render_tag_with_block
    define_tag('test') { |tag| "Hello #{tag.expand}!" }
    define_tag('hello') { |tag| tag.render('test') { tag.expand } }
    assert_parse_output 'Hello John!', '<r:hello>John</r:hello>'
  end
  
  def test_tag_locals
    define_tag "outer" do |tag|
      tag.locals.var = 'outer'
      tag.expand
    end
    define_tag "outer:inner" do |tag|
      tag.locals.var = 'inner'
      tag.expand
    end
    define_tag "outer:var" do |tag|
      tag.locals.var
    end
    assert_parse_output 'outer', "<r:outer><r:var /></r:outer>"
    assert_parse_output 'outer:inner:outer', "<r:outer><r:var />:<r:inner><r:var /></r:inner>:<r:var /></r:outer>"
    assert_parse_output 'outer:inner:outer:inner:outer', "<r:outer><r:var />:<r:inner><r:var />:<r:outer><r:var /></r:outer>:<r:var /></r:inner>:<r:var /></r:outer>"
    assert_parse_output 'outer', "<r:outer:var />"
  end
  
  def test_tag_globals
    define_tag "set" do |tag|
      tag.globals.var = tag.attr['value']
      ''
    end
    define_tag "var" do |tag|
      tag.globals.var
    end
    assert_parse_output "  true  false", %{<r:var /> <r:set value="true" /> <r:var /> <r:set value="false" /> <r:var />}
  end
  
  def test_parse_loops
    @item = nil
    define_tag "each" do |tag|
      result = []
      ["Larry", "Moe", "Curly"].each do |item|
        tag.locals.item = item
        result << tag.expand
      end
      result.join(tag.attr["between"] || "")
    end
    define_tag "each:item" do |tag|
      tag.locals.item
    end
    assert_parse_output %{Three Stooges: "Larry", "Moe", "Curly"}, %{Three Stooges: <r:each between=", ">"<r:item />"</r:each>}
  end
  
  def test_tag_option_for
    define_tag 'fun', :for => 'just for kicks'
    assert_parse_output 'just for kicks', '<r:fun />'
  end
  
  def test_tag_expose_option
    define_tag 'user', :for => users.first, :expose => ['name', :age]
    assert_parse_output 'John', '<r:user:name />'
    assert_parse_output '25', '<r:user><r:age /></r:user>'
    e = assert_raises(Radius::UndefinedTagError) { @parser.parse "<r:user:email />" }
    assert_equal "undefined tag `email'", e.message
  end
  
  def test_tag_expose_attributes_option_on_by_default
    define_tag 'user', :for => user_with_attributes
    assert_parse_output 'John', '<r:user:name />'
  end
  def test_tag_expose_attributes_set_to_false
    define_tag 'user_without_attributes', :for => user_with_attributes, :attributes => false
    assert_raises(Radius::UndefinedTagError) { @parser.parse "<r:user_without_attributes:name />" }
  end
  
  def test_tag_options_must_contain_a_for_option_if_methods_are_exposed
    e = assert_raises(ArgumentError) { define_tag('fun', :expose => :today) { 'test' } }
    assert_equal "tag definition must contain a :for option when used with the :expose option", e.message
  end
  
  def test_parse_fail_on_missing_end_tag
    assert_raises(Radius::MissingEndTagError) { @parser.parse("<r:reverse>") }
    assert_raises(Radius::MissingEndTagError) { @parser.parse("<r:reverse><r:capitalize></r:reverse>") }
  end
  
  protected
  
    def assert_parse_output(output, input, message = nil)
      r = @parser.parse(input)
      assert_equal(output, r, message)
    end
    
    def assert_parsed_is_unchanged(something)
      assert_parse_output something, something
    end
    
    class User
      attr_accessor :name, :age, :email, :friend
      def initialize(name, age, email)
        @name, @age, @email = name, age, email
      end
      def <=>(other)
        name <=> other.name
      end
    end
    
    class UserWithAttributes < User
      def attributes
        { :name => name, :age => age, :email => email }
      end
    end
    
    def users
      [
        User.new('John', 25, 'test@johnwlong.com'),
        User.new('James', 27, 'test@jameslong.com')
      ]
    end
    
    def user_with_attributes
      UserWithAttributes.new('John', 25, 'test@johnwlong.com')
    end
  
end
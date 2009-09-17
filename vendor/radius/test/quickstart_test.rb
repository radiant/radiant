require File.join(File.dirname(__FILE__), 'test_helper')

class QuickstartTest < Test::Unit::TestCase

  def test_hello_world
    context = Radius::Context.new
    context.define_tag "hello" do |tag|
      "Hello #{tag.attr['name'] || 'World'}!"
    end
    parser = Radius::Parser.new(context)
    assert_equal "<p>Hello World!</p>", parser.parse('<p><radius:hello /></p>')
    assert_equal "<p>Hello John!</p>", parser.parse('<p><radius:hello name="John" /></p>')
  end
  
  def test_example_2
    require 'redcloth'
    context = Radius::Context.new
    context.define_tag "textile" do |tag|
      contents = tag.expand
      RedCloth.new(contents).to_html
    end
    parser = Radius::Parser.new(context)
    assert_equal "<h1>Hello <b>World</b>!</h1>", parser.parse('<radius:textile>h1. Hello **World**!</radius:textile>')
  end
  
  def test_nested_example
    context = Radius::Context.new
    
    context.define_tag "stooge" do |tag|
      content = ''
      ["Larry", "Moe", "Curly"].each do |name|
        tag.locals.name = name
        content << tag.expand
      end
      content
    end
    
    context.define_tag "stooge:name" do |tag|
      tag.locals.name
    end
    
    parser = Radius::Parser.new(context)
    
    template = <<-TEMPLATE
<ul>
<radius:stooge>
  <li><radius:name /></li>
</radius:stooge>
</ul>
    TEMPLATE
    
    output = <<-OUTPUT
<ul>

  <li>Larry</li>

  <li>Moe</li>

  <li>Curly</li>

</ul>
    OUTPUT
    
    assert_equal output, parser.parse(template)
  end
  
  class User
    attr_accessor :name, :age, :email
  end
  def test_exposing_objects_example
    context = Radius::Context.new
    parser = Radius::Parser.new(context)
    
    context.define_tag "count", :for => 1
    assert_equal "1", parser.parse("<radius:count />")
    
    user = User.new
    user.name, user.age, user.email = "John", 29, "john@example.com"
    context.define_tag "user", :for => user, :expose => [ :name, :age, :email ]
    assert_equal "John", parser.parse("<radius:user><radius:name /></radius:user>")
    
    assert_equal "John", parser.parse("<radius:user:name />")
  end
  
  class LazyContext < Radius::Context
    def tag_missing(tag, attr, &block)
      "<strong>ERROR: Undefined tag `#{tag}' with attributes #{attr.inspect}</strong>"
    end
  end
  def test_tag_missing_example
    parser = Radius::Parser.new(LazyContext.new, :tag_prefix => 'lazy')
    output = %{<strong>ERROR: Undefined tag `weird' with attributes {"value"=>"true"}</strong>}
    assert_equal output, parser.parse('<lazy:weird value="true" />')
  end
  
  def test_tag_globals_example
    context = Radius::Context.new
    parser = Radius::Parser.new(context)
    
    context.define_tag "inc" do |tag|
      tag.globals.count ||= 0
      tag.globals.count += 1
      ""
    end
    
    context.define_tag "count" do |tag|
      tag.globals.count || 0
    end
    
    assert_equal "0 1", parser.parse("<radius:count /> <radius:inc /><radius:count />")
  end
  
  class Person
    attr_accessor :name, :friend
    def initialize(name)
      @name = name
    end
  end
  def test_tag_locals_and_globals_example
    jack = Person.new('Jack')
    jill = Person.new('Jill')
    jack.friend = jill
    jill.friend = jack
    
    context = Radius::Context.new do |c|
      c.define_tag "jack" do |tag|
        tag.locals.person = jack
        tag.expand
      end
      c.define_tag "jill" do |tag|
        tag.locals.person = jill
        tag.expand
      end
      c.define_tag "name" do |tag|
        tag.locals.person.name rescue tag.missing!
      end
      c.define_tag "friend" do |tag|
        tag.locals.person = tag.locals.person.friend rescue tag.missing!
        tag.expand
      end
    end
    
    parser = Radius::Parser.new(context, :tag_prefix => 'r')
    
    assert_equal "Jack", parser.parse('<r:jack:name />') #=> "Jack"
    assert_equal "Jill", parser.parse('<r:jill:name />') #=> "Jill"
    assert_equal "Jack", parser.parse('<r:jill:friend:name />') #=> "Jack"
    assert_equal "Jack", parser.parse('<r:jack:friend:friend:name />') #=> "Jack"
    assert_equal "Jack and Jill", parser.parse('<r:jill><r:friend:name /> and <r:name /></r:jill>') #=> "Jack and Jill"
    assert_raises(Radius::UndefinedTagError) { parser.parse('<r:name />') } # raises a Radius::UndefinedTagError exception
  end
  
end
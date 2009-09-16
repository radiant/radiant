module Radius
  #
  # A tag binding is passed into each tag definition and contains helper methods for working
  # with tags. Use it to gain access to the attributes that were passed to the tag, to
  # render the tag contents, and to do other tasks.
  #
  class TagBinding
    # The Context that the TagBinding is associated with. Used internally. Try not to use
    # this object directly.
    attr_reader :context
  
    # The locals object for the current tag.
    attr_reader :locals
  
    # The name of the tag (as used in a template string).
    attr_reader :name
  
    # The attributes of the tag. Also aliased as TagBinding#attr.
    attr_reader :attributes
    alias :attr :attributes
  
    # The render block. When called expands the contents of the tag. Use TagBinding#expand
    # instead.
    attr_reader :block
  
    # Creates a new TagBinding object.
    def initialize(context, locals, name, attributes, block)
      @context, @locals, @name, @attributes, @block = context, locals, name, attributes, block
    end
  
    # Evaluates the current tag and returns the rendered contents.
    def expand
      double? ? block.call : ''
    end

    # Returns true if the current tag is a single tag.
    def single?
      block.nil?
    end

    # Returns true if the current tag is a container tag.
    def double?
      not single?
    end
  
    # The globals object from which all locals objects ultimately inherit their values.
    def globals
      @context.globals
    end
  
    # Returns a list of the way tags are nested around the current tag as a string.
    def nesting
      @context.current_nesting
    end
  
    # Fires off Context#tag_missing for the current tag.
    def missing!
      @context.tag_missing(name, attributes, &block)
    end
  
    # Renders the tag using the current context .
    def render(tag, attributes = {}, &block)
      @context.render_tag(tag, attributes, &block)
    end
  
    # Shortcut for accessing tag.attr[key]
    def [](key)
      attr[key]
    end
  end
end
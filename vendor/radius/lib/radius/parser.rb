module Radius
  #
  # The Radius parser. Initialize a parser with a Context object that
  # defines how tags should be expanded. See the QUICKSTART[link:files/QUICKSTART.html]
  # for a detailed explaination of its usage.
  #
  class Parser
    # The Context object used to expand template tags.
    attr_accessor :context
  
    # The string that prefixes all tags that are expanded by a parser
    # (the part in the tag name before the first colon).
    attr_accessor :tag_prefix
  
    # Creates a new parser object initialized with a Context.
    def initialize(context = Context.new, options = {})
      if context.kind_of?(Hash) and options.empty?
        options = context
        context = options[:context] || options['context'] || Context.new
      end
      options = Utility.symbolize_keys(options)
      @context = context
      @tag_prefix = options[:tag_prefix] || 'radius'
    end

    # Parses string for tags, expands them, and returns the result.
    def parse(string)
      @stack = [ParseContainerTag.new { |t| t.contents.to_s }]
      tokenize(string)
      stack_up
      @stack.last.to_s
    end

    protected
    # Convert the string into a list of text blocks and scanners (tokens)
    def tokenize(string)
      @tokens = Scanner::operate(tag_prefix, string)
    end
    
    def stack_up
      @tokens.each do |t|
        if t.is_a? String
          @stack.last.contents << t
          next
        end
        case t[:flavor]
        when :open
          @stack.push(ParseContainerTag.new(t[:name], t[:attrs]))
        when :self
          @stack.last.contents << ParseTag.new {@context.render_tag(t[:name], t[:attrs])}
        when :close
          popped = @stack.pop
          raise WrongEndTagError.new(popped.name, t[:name], @stack) if popped.name != t[:name]
          popped.on_parse { |b| @context.render_tag(popped.name, popped.attributes) { b.contents.to_s } }
          @stack.last.contents << popped
        when :tasteless
          raise TastelessTagError.new(t, @stack)
        else
          raise UndefinedFlavorError.new(t, @stack)
        end
      end
      raise MissingEndTagError.new(@stack.last.name, @stack) if @stack.length != 1
    end
  end
end
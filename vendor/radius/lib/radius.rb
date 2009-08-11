#--
# Copyright (c) 2006, John W. Long
#
# Permission is hereby granted, free of charge, to any person obtaining a copy of this
# software and associated documentation files (the "Software"), to deal in the Software
# without restriction, including without limitation the rights to use, copy, modify,
# merge, publish, distribute, sublicense, and/or sell copies of the Software, and to
# permit persons to whom the Software is furnished to do so, subject to the following
# conditions:
#
# The above copyright notice and this permission notice shall be included in all copies
# or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
# INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A
# PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
# HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF
# CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE
# OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
#++
module Radius
  # Abstract base class for all parsing errors.
  class ParseError < StandardError
  end
  
  # Occurs when Parser cannot find an end tag for a given tag in a template or when
  # tags are miss-matched in a template.
  class MissingEndTagError < ParseError
    # Create a new MissingEndTagError object for +tag_name+. 
    def initialize(tag_name)
      super("end tag not found for start tag `#{tag_name}'")
    end
  end
  
  # Occurs when Context#render_tag cannot find the specified tag on a Context.
  class UndefinedTagError < ParseError
    # Create a new UndefinedTagError object for +tag_name+. 
    def initialize(tag_name)
      super("undefined tag `#{tag_name}'")
    end
  end
  
  module TagDefinitions # :nodoc:
    class TagFactory # :nodoc:
      def initialize(context)
        @context = context
      end
      
      def define_tag(name, options, &block)
        options = prepare_options(name, options)
        validate_params(name, options, &block)
        construct_tag_set(name, options, &block)
        expose_methods_as_tags(name, options)
      end
      
      protected

        # Adds the tag definition to the context. Override in subclasses to add additional tags
        # (child tags) when the tag is created.
        def construct_tag_set(name, options, &block)
          if block
            @context.definitions[name.to_s] = block
          else
            lp = last_part(name)
            @context.define_tag(name) do |tag|
              if tag.single?
                options[:for]
              else
                tag.locals.send("#{ lp }=", options[:for]) unless options[:for].nil?
                tag.expand
              end
            end
          end
        end

        # Normalizes options pased to tag definition. Override in decendants to preform
        # additional normalization.
        def prepare_options(name, options)
          options = Util.symbolize_keys(options)
          options[:expose] = expand_array_option(options[:expose])
          object = options[:for]
          options[:attributes] = object.respond_to?(:attributes) unless options.has_key? :attributes
          options[:expose] += object.attributes.keys if options[:attributes]
          options
        end
        
        # Validates parameters passed to tag definition. Override in decendants to add custom
        # validations.
        def validate_params(name, options, &block)
          unless options.has_key? :for
            raise ArgumentError.new("tag definition must contain a :for option or a block") unless block
            raise ArgumentError.new("tag definition must contain a :for option when used with the :expose option") unless options[:expose].empty?
          end
        end
        
        # Exposes the methods of an object as child tags.
        def expose_methods_as_tags(name, options)
          options[:expose].each do |method|
            tag_name = "#{name}:#{method}"
            lp = last_part(name)
            @context.define_tag(tag_name) do |tag|
              object = tag.locals.send(lp)
              object.send(method)
            end
          end
        end
        
      protected
      
        def expand_array_option(value)
          [*value].compact.map { |m| m.to_s.intern }
        end
        
        def last_part(name)
          name.split(':').last
        end
    end
  end
    
  class DelegatingOpenStruct # :nodoc:
    attr_accessor :object
    
    def initialize(object = nil)
      @object = object
      @hash = {}
    end
    
    def method_missing(method, *args, &block)
      symbol = (method.to_s =~ /^(.*?)=$/) ? $1.intern : method
      if (0..1).include?(args.size)
        if args.size == 1
          @hash[symbol] = args.first
        else
          if @hash.has_key?(symbol)
            @hash[symbol]
          else
            unless object.nil?
              @object.send(method, *args, &block)
            else
              nil
            end
          end
        end
      else
        super
      end
    end
  end
  
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
  
  #
  # A context contains the tag definitions which are available for use in a template.
  # See the QUICKSTART[link:files/QUICKSTART.html] for a detailed explaination its
  # usage.
  #
  class Context
    # A hash of tag definition blocks that define tags accessible on a Context.
    attr_accessor :definitions # :nodoc:
    attr_accessor :globals # :nodoc:
    
    # Creates a new Context object.
    def initialize(&block)
      @definitions = {}
      @tag_binding_stack = []
      @globals = DelegatingOpenStruct.new
      with(&block) if block_given?
    end
    
    # Yeild an instance of self for tag definitions:
    #
    #   context.with do |c|
    #     c.define_tag 'test' do
    #       'test'
    #     end
    #   end
    #
    def with
      yield self
      self
    end
    
    # Creates a tag definition on a context. Several options are available to you
    # when creating a tag:
    # 
    # +for+::             Specifies an object that the tag is in reference to. This is
    #                     applicable when a block is not passed to the tag, or when the
    #                     +expose+ option is also used.
    #
    # +expose+::          Specifies that child tags should be set for each of the methods
    #                     contained in this option. May be either a single symbol/string or
    #                     an array of symbols/strings.
    #
    # +attributes+::      Specifies whether or not attributes should be exposed
    #                     automatically. Useful for ActiveRecord objects. Boolean. Defaults
    #                     to +true+.
    #
    def define_tag(name, options = {}, &block)
      type = Util.impartial_hash_delete(options, :type).to_s
      klass = Util.constantize('Radius::TagDefinitions::' + Util.camelize(type) + 'TagFactory') rescue raise(ArgumentError.new("Undefined type `#{type}' in options hash"))
      klass.new(self).define_tag(name, options, &block)
    end

    # Returns the value of a rendered tag. Used internally by Parser#parse.
    def render_tag(name, attributes = {}, &block)
      if name =~ /^(.+?):(.+)$/
        render_tag($1) { render_tag($2, attributes, &block) }
      else
        tag_definition_block = @definitions[qualified_tag_name(name.to_s)]
        if tag_definition_block
          stack(name, attributes, block) do |tag|
            tag_definition_block.call(tag).to_s
          end
        else
          tag_missing(name, attributes, &block)
        end
      end
    end

    # Like method_missing for objects, but fired when a tag is undefined.
    # Override in your own Context to change what happens when a tag is
    # undefined. By default this method raises an UndefinedTagError.
    def tag_missing(name, attributes, &block)
      raise UndefinedTagError.new(name)
    end

    # Returns the state of the current render stack. Useful from inside
    # a tag definition. Normally just use TagBinding#nesting.
    def current_nesting
      @tag_binding_stack.collect { |tag| tag.name }.join(':')
    end

    private

      # A convienence method for managing the various parts of the
      # tag binding stack.
      def stack(name, attributes, block)
        previous = @tag_binding_stack.last
        previous_locals = previous.nil? ? @globals : previous.locals
        locals = DelegatingOpenStruct.new(previous_locals)
        binding = TagBinding.new(self, locals, name, attributes, block)
        @tag_binding_stack.push(binding)
        result = yield(binding)
        @tag_binding_stack.pop
        result
      end

      # Returns a fully qualified tag name based on state of the
      # tag binding stack.
      def qualified_tag_name(name)
        nesting_parts = @tag_binding_stack.collect { |tag| tag.name }
        nesting_parts << name unless nesting_parts.last == name
        specific_name = nesting_parts.join(':') # specific_name always has the highest specificity
        unless @definitions.has_key? specific_name
          possible_matches = @definitions.keys.grep(/(^|:)#{name}$/)
          specificity = possible_matches.inject({}) { |hash, tag| hash[numeric_specificity(tag, nesting_parts)] = tag; hash }
          max = specificity.keys.max
          if max != 0
            specificity[max]
          else
            name
          end
        else
          specific_name
        end
      end
      
      # Returns the specificity for +tag_name+ at nesting defined
      # by +nesting_parts+ as a number.
      def numeric_specificity(tag_name, nesting_parts)
        nesting_parts = nesting_parts.dup
        name_parts = tag_name.split(':')
        specificity = 0
        value = 1
        if nesting_parts.last == name_parts.last
          while nesting_parts.size > 0
            if nesting_parts.last == name_parts.last
              specificity += value
              name_parts.pop
            end
            nesting_parts.pop
            value *= 0.1
          end
          specificity = 0 if (name_parts.size > 0)
        end
        specificity
      end
  end

  class ParseTag # :nodoc:
    def initialize(&b)
      @block = b
    end

    def on_parse(&b)
      @block = b
    end

    def to_s
      @block.call(self)
    end
  end

  class ParseContainerTag < ParseTag # :nodoc:
    attr_accessor :name, :attributes, :contents
    
    def initialize(name = "", attributes = {}, contents = [], &b)
      @name, @attributes, @contents = name, attributes, contents
      super(&b)
    end
  end

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
      options = Util.symbolize_keys(options)
      @context = context
      @tag_prefix = options[:tag_prefix]
    end

    # Parses string for tags, expands them, and returns the result.
    def parse(string)
      @stack = [ParseContainerTag.new { |t| t.contents.to_s }]
      pre_parse(string)
      @stack.last.to_s
    end

    protected

      def pre_parse(text) # :nodoc:
        re = %r{<#{@tag_prefix}:([\w:]+?)(\s+(?:\w+\s*=\s*(?:"[^"]*?"|'[^']*?')\s*)*|)>|</#{@tag_prefix}:([\w:]+?)\s*>}
        if md = re.match(text)
          start_tag, attr, end_tag = $1, $2, $3
          @stack.last.contents << ParseTag.new { parse_individual(md.pre_match) }
          remaining = md.post_match
          if start_tag
            parse_start_tag(start_tag, attr, remaining)
          else
            parse_end_tag(end_tag, remaining)
          end
        else
          if @stack.length == 1
            @stack.last.contents << ParseTag.new { parse_individual(text) }
          else
            raise MissingEndTagError.new(@stack.last.name)
          end
        end
      end

      def parse_start_tag(start_tag, attr, remaining) # :nodoc:
        @stack.push(ParseContainerTag.new(start_tag, parse_attributes(attr)))
        pre_parse(remaining)
      end

      def parse_end_tag(end_tag, remaining) # :nodoc:
        popped = @stack.pop
        if popped.name == end_tag
          popped.on_parse { |t| @context.render_tag(popped.name, popped.attributes) { t.contents.to_s } }
          tag = @stack.last
          tag.contents << popped
          pre_parse(remaining)
        else
          raise MissingEndTagError.new(popped.name)
        end
      end

      def parse_individual(text) # :nodoc:
        re = %r{<#{@tag_prefix}:([\w:]+?)(\s+(?:\w+\s*=\s*(?:"[^"]*?"|'[^']*?')\s*)*|)/>}
        if md = re.match(text)
          attr = parse_attributes($2)
          replace = @context.render_tag($1, attr)
          md.pre_match + replace + parse_individual(md.post_match)
        else
          text || ''
        end
      end

      def parse_attributes(text) # :nodoc:
        attr = {}
        re = /(\w+?)\s*=\s*('|")(.*?)\2/
        while md = re.match(text)
          attr[$1] = $3
          text = md.post_match
        end
        attr
      end
  end

  module Util # :nodoc:
    def self.symbolize_keys(hash)
      new_hash = {}
      hash.keys.each do |k|
        new_hash[k.to_s.intern] = hash[k]
      end
      new_hash
    end
    
    def self.impartial_hash_delete(hash, key)
      string = key.to_s
      symbol = string.intern
      value1 = hash.delete(symbol)
      value2 = hash.delete(string)
      value1 || value2
    end
    
    def self.constantize(camelized_string)
      raise "invalid constant name `#{camelized_string}'" unless camelized_string.split('::').all? { |part| part =~ /^[A-Za-z]+$/ }
      Object.module_eval(camelized_string)
    end
    
    def self.camelize(underscored_string)
      string = ''
      underscored_string.split('_').each { |part| string << part.capitalize }
      string
    end
  end
  
end
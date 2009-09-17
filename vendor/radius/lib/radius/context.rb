module Radius
  #
  # A context contains the tag definitions which are available for use in a template.
  # See the QUICKSTART for a detailed explaination its
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
      type = Utility.impartial_hash_delete(options, :type).to_s
      klass = Utility.constantize('Radius::TagDefinitions::' + Utility.camelize(type) + 'TagFactory') rescue raise(ArgumentError.new("Undefined type `#{type}' in options hash"))
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
end

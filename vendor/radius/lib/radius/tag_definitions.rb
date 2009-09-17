module Radius
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
          options = Utility.symbolize_keys(options)
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
end

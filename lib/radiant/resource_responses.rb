require 'ostruct'
module Radiant
  module ResourceResponses
    def self.extended(base)
      base.send :class_inheritable_writer, :responses
      base.send :include, InstanceMethods
    end
    
    def responses
      self.responses = Collector.new unless read_inheritable_attribute(:responses)
      returning read_inheritable_attribute(:responses) do |r|
        yield r if block_given?
      end
    end
    
    module InstanceMethods
      def response_for(action)
        responses = self.class.responses.send(action)
        respond_to do |wants|
          responses.each_format do |f, format_block|
            if format_block
              wants.send(f, &wrap(format_block))
            else
              wants.send(f)
            end
          end
          responses.each_published do |pub, pub_block|
            wants.send(pub, &wrap(pub_block))
          end
          if responses.default
            wants.any(&wrap(responses.default))
          else
            wants.any
          end
        end
      end
      
      def wrap(proc)
        # Makes sure our response blocks get evaluated in the right context
        lambda do
          instance_eval(&proc)
        end
      end
    end
    
    class Collector < OpenStruct
      def initialize
        super
        @table = Hash.new {|h,k| h[k] = Response.new }
      end
    end
    
    class Response
      attr_reader :publish_formats, :publish_block, :blocks
      def initialize
        @publish_formats = []
        @blocks = {}
        @block_order = []
      end
      
      def default(&block)
        if block_given?
          @default = block
        end
        @default
      end
      
      def publish(*formats, &block)
        @publish_formats.concat(formats)
        if block_given?
          @publish_block = block 
        else
          raise ArgumentError, "Block required to publish" unless @publish_block
        end
      end
      
      def each_published
        publish_formats.each do |format|
          yield format, publish_block if block_given?
        end
      end

      def each_format
        @block_order.each do |format|
          yield format, @blocks[format] if block_given?
        end
      end

      def method_missing(method, *args, &block)
        if block_given?
          @blocks[method] = block
          @block_order << method unless @block_order.include?(method)
        elsif args.empty?
          @block_order << method
        else
          super
        end
      end
    end
  end
end
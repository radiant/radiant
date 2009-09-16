module Radius
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
end

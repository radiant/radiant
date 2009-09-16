module Radius
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
end
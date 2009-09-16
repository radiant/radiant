module Radius
  # Abstract base class for all parsing errors.
  class ParseError < StandardError
  end
  
  # Occurs when the Parser expects an end tag for one tag and finds the end tag for another.
  class WrongEndTagError < ParseError
    def initialize(expected_tag, got_tag, stack)
      stack_message = " with stack #{stack.inspect}" if stack
      super("wrong end tag `#{got_tag}' found for start tag `#{expected_tag}'#{stack_message}")
    end
  end
  
  # Occurs when Parser cannot find an end tag for a given tag in a template or when
  # tags are miss-matched in a template.
  class MissingEndTagError < ParseError
    # Create a new MissingEndTagError object for +tag_name+. 
    def initialize(tag_name, stack)
      stack_message = " with stack #{stack.inspect}" if stack
      super("end tag not found for start tag `#{tag_name}'#{stack_message}")
    end
  end
  
  # Occurs when Context#render_tag cannot find the specified tag on a Context.
  class UndefinedTagError < ParseError
    # Create a new UndefinedTagError object for +tag_name+. 
    def initialize(tag_name)
      super("undefined tag `#{tag_name}'")
    end
  end
  
  class TastelessTagError < ParseError #:nodoc:
    def initialize(tag, stack)
      super("internal error with tasteless tag #{tag.inspect} and stack #{stack.inspect}")
    end
  end
  
  class UndefinedFlavorError < ParseError #:nodoc:
    def initialize(tag, stack)
      super("internal error with unknown flavored tag #{tag.inspect} and stack #{stack.inspect}")
    end
  end
end
module Radius
  class TagBinding
    def expand
      (double? ? block.call : '').html_safe
    end
  end
end

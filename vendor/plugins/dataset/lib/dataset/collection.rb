require 'set'

module Dataset
  class Collection < Array # :nodoc:
    def initialize(parent)
      concat parent
    end
    
    def <<(dataset)
      super
      uniq!
      self
    end
    
    def subset?(other)
      Set.new(self).subset?(Set.new(other))
    end
  end
end
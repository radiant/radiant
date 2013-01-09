unless defined? Radiant::Version
  module Radiant
    module Version
      Major = '2'
      Minor = '0'
      Tiny  = '0'
      Patch = 'alpha' # set to nil for normal release

      class << self
        def to_s
          [Major, Minor, Tiny, Patch].compact.join('.')
        end
        alias :to_str :to_s
      end
    end
  end
end
module Spec
  module Rails
    module VERSION #:nodoc:
      unless defined? MAJOR
        MAJOR  = 1
        MINOR  = 1
        TINY   = 4

        STRING = [MAJOR, MINOR, TINY].join('.')

        SUMMARY = "rspec-rails version #{STRING}"
      end
    end
  end
end
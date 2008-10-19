module Spec
  module Rails
    module VERSION #:nodoc:
      unless defined? MAJOR
        MAJOR  = 1
        MINOR  = 1
        TINY   = 8

        STRING = [MAJOR, MINOR, TINY].join('.')

        SUMMARY = "rspec-rails #{STRING}"
      end
    end
  end
end
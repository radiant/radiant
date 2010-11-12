module Radius
  class OrdString < String
    if RUBY_VERSION[0,3] == '1.9'
      def [](*args)
        if args.size == 1 && args.first.is_a?(Integer)
          slice(args.first).ord
        else
          super
        end
      end
    end
  end
end
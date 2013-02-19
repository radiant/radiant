module Radiant
  class AdminUI
    class RegionPartials
      def initialize(template)
        @partials = Hash.new {|h,k| h[k] = "<strong>`#{k}' default partial not found!</strong>" }
        @template = template
      end

      def [](key)
        @partials[key.to_s]
      end

      def method_missing(method, *args, &block)
        if block_given?
          # Ruby 1.9.2 yields self in instance_eval... see https://gist.github.com/479572
          # lambdas are as strict as methods in 1.9.x, making sure that the args match, Procs are not.
          if RUBY_VERSION =~ /^1\.9/ and block.lambda? and block.arity != 1
            raise "You can only pass a proc ('Proc.new') or a lambda that takes exactly one arg (for self) to Radiant::AdminUI::RegionPartials' method_missing."
          end
          @partials[method.to_s] = @template.capture(&block)
        else
          @partials[method.to_s]
        end
      end
    end
  end
end
module Spec
  module Rails
    module Matchers
      class LoginRequirement
        def initialize(example)
          @example = example
        end

        def matches?(proc)
          proc.call
          @response = @example.response
          @was_redirect = @response.redirect?
          @was_redirect_to_login = @response.redirect_url_match?("/admin/login")
          @was_redirect && @was_redirect_to_login
        end

        def failure_message
          if @was_redirect
            "expected to redirect to /admin/login but redirected to #{@response.redirect_url}"
          else
            "expected to require login but did not redirect"
          end
        end

        def negative_failure_message
          "expected not to require login"
        end
      end

      class ActionRestriction
        def initialize(options, example)
          @allow = [options[:allow]].flatten.compact
          @deny = [options[:deny]].flatten.compact
          @url = options[:url]
          @example = example
        end

        def matches?(proc)
          @proc = proc
          @result = {}
          @urls = {}
          @allow.all? {|u| !denied?(u) } && @deny.all? {|u| denied?(u) }
        end

        def failure_message
          message = []
          @allow.each do |user|
            message << "expected to allow user #{user.name} but was denied" if @result[user]
          end
          @deny.each do |user|
            if !@result[user]
              message << "expected to deny user #{user.name} but was allowed"
            elsif @urls[user]
              message << "expected to redirect user #{user.name} to #{@url} but redirected to #{@urls[user]}"
            end
          end
          message.to_sentence
        end

        private
          def denied?(user)
            @example.request.session['user_id'] = user.id
            @proc.call
            response = @example.response
            @urls[user] = response.redirect_url if @url && !response.redirect_url_match?(@url)
            @result[user] = response.redirect? && (@url.nil? || response.redirect_url_match?(@url))
          end
      end

      def require_login
        LoginRequirement.new(self)
      end

      def restrict_access(options)
        ActionRestriction.new(options, self)
      end
    end
  end
end

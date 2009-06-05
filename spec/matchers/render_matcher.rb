module Spec
  module Rails
    module Matchers
      
      class RenderTags
        def initialize(content = nil)
          @content = content
        end
        
        def matches?(page)
          @actual = render_content_with_page(@content, page)
          if @expected.kind_of?(Regexp)
            @expected = nil
            @matching = @expected
          end
          case
            when @expected_error_message: false
            when @expected: @actual == @expected
            when @matching: @actual =~ @matching
            else true
          end
        rescue => @actual_error
          if @expected_error_message
            @actual_error.message === @expected_error_message
          else
            @error_thrown = true
            false
          end
        end
        
        def failure_message
          action = @expected.nil? ? "render and match #{@matching.inspect}" : "render as #{@expected.inspect}"
          unless @error_thrown
            unless @expected_error_message
              if @content
                "expected #{@content.inspect} to #{action}, but got #{@actual.inspect}"
              else
                "expected page to #{action}, but got #{@actual.inspect}"
              end
            else
              if @actual_error
                "expected rendering #{@content.inspect} to throw exception with message #{@expected_error_message.inspect}, but was #{@actual_error.message.inspect}"
              else
                "expected rendering #{@content.inspect} to throw exception with message #{@expected_error_message.inspect}, but no exception thrown. Rendered #{@actual.inspect} instead."
              end
            end
          else
            "expected #{@content.inspect} to render, but an exception was thrown #{@actual_error.message}"
          end
        end
        
        def description
          "render tags #{@expected.inspect}"
        end
        
        def as(output)
          @expected = output
          self
        end
        
        def matching(regexp)
          @matching = regexp
          self
        end
        
        def with_error(message)
          @expected_error_message = message
          self
        end
        
        def on(url)
          url = test_host + "/" + url unless url =~ %r{^[^/]+\.[^/]+}
          url = 'http://' + url unless url =~ %r{^http://}
          uri = URI.parse(url)
          @request_uri = uri.request_uri unless uri.request_uri == '/'
          @host = uri.host
          self
        end
        
        def with_relative_root(url="/")
          @relative_root = url
          self
        end
        
        private
          def render_content_with_page(tag_content, page)
            page.request = ActionController::TestRequest.new
            page.request.params[:sample_param] = 'data'
            page.request.request_uri = @request_uri || page.url
            page.request.host = @host || test_host
            ActionController::Base.relative_url_root = @relative_root
            page.response = ActionController::TestResponse.new
            if tag_content.nil?
              page.render
            else
              page.send(:parse, tag_content)
            end
          end
          
          def test_host
            "testhost.tld"
          end
      end
      
      # page.should render(input).as(output)
      # page.should render(input).as(output).on(url)
      # page.should render(input).matching(/hello world/)
      # page.should render(input).with_error(message)
      def render(input)
        RenderTags.new(input)
      end
      
      # page.should render_as(output)
      def render_as(output)
        RenderTags.new.as(output)
      end
      
    end
  end
end
module RenderTestHelper
  
  def assert_renders(expected, input, url = nil, host = nil)
    output = get_render_output(input, url, host)
    message = "<#{expected.inspect}> expected but was <#{output.inspect}>"
    assert_block(message) { expected == output }
  end
  
  def assert_render_match(regexp, input, url = nil)
    regexp = Regexp.new(regexp) if regexp.kind_of? String
    output = get_render_output(input, url)
    message = "<#{output.inspect}> expected to be =~ <#{regexp.inspect}>"
    assert_block(message) { output =~ regexp }
  end
  
  def assert_render_error(expected_error_message, input, url = nil)
    output = get_render_output(input, url)
    message = "expected error message <#{expected_error_message.inspect}> expected but none was thrown"
    assert_block(message) { false }
  rescue => e
    message = "expected error message <#{expected_error_message.inspect}> but was <#{e.message.inspect}>"
    assert_block(message) { expected_error_message === e.message }
  end
  
  def assert_headers(expected_headers, url = nil)
    setup_page(url)
    headers = @page.headers
    message = "<#{expected_headers.inspect}> expected but was <#{headers.inspect}>"
    assert_block(message) { expected_headers == headers }
  end
  
  def assert_page_renders(page_name, expected, message = nil)
    page = pages(page_name)
    output = page.render
    message = "<#{expected.inspect}> expected, but was <#{output.inspect}>"
    assert_block(message) { expected == output }
  end
  
  def assert_snippet_renders(snippet_name, expected, message = nil)
    snippet = snippets(snippet_name)
    output = @page.render_snippet(snippet)
    message = "<#{expected.inspect}> expected, but was <#{output.inspect}>"
    assert_block(message) { expected == output }
  end
  
  private
  
    def get_render_output(input, url, host = nil)
      setup_page(url, host)
      @page.send(:parse, input)
    end
    
    def setup_page(url = nil, host = nil)
      @page.request = ActionController::TestRequest.new
      @page.request.request_uri = (url || @page.url)
      @page.request.host = host || "testhost.tld"
      @page.response = ActionController::TestResponse.new
    end
  
end

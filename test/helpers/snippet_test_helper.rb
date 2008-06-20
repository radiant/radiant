module SnippetTestHelper
  VALID_SNIPPET_PARAMS = {
    :name => 'test-snippet',
    :content => 'Funness'
  }
  
  def snippet_params(options = {})
    params = VALID_SNIPPET_PARAMS.dup
    params.merge!(:name => @snippet_name) if @snippet_name
    params.merge!(options)
  end
  
  def destroy_test_snippet(name = @snippet_name)
    while snippet = get_test_snippet(name) do
      snippet.destroy
    end
  end
  
  def get_test_snippet(name = @snippet_name)
    Snippet.find_by_name(name)
  end
  
  def create_test_snippet(options = {})
    options[:name] ||= @snippet_name if @snippet_name
    snippet = Snippet.new snippet_params(options)
    if snippet.save
      snippet
    else
      raise "snippet <#{snippet.inspect}> could not be saved"
    end
  end
end
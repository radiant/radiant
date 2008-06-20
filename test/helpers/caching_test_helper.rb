class FakeResponseCache
  attr_accessor :expired_path, :expired_paths
  
  def initialize
    @expired_paths = []
    @cached_responses = {}
  end
  
  def clear
    @cached_responses.clear
    @cleared = true
  end
  
  def cache_response(path, response)
    @cached_responses[path] = response
    response
  end
  
  def update_response(path, response)
    if r = @cached_response[path]
      response.headers.merge!(r.headers)
      response.body = r.body
    end
    response
  end
  
  def expire_response(path)
    @expired_paths << path
    @expired_path = path
  end
  
  def response_cached?(path)
    @cached_responses.keys.include?(path)
  end
  
  def cleared?
    !!@cleared
  end
end

module CachingTestHelper
end
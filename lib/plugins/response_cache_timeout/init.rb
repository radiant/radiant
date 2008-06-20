ActionController::AbstractResponse.class_eval do
  attr_accessor :cache_timeout
end

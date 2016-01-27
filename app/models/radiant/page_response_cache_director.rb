module Radiant
  class PageResponseCacheDirector
    def initialize(page, listener)
      @page = page
      @listener = listener
    end

    def set_cache_control
      cacheable? ? cacheable_response : non_cacheable_response
    end

    class << self
      def cache_timeout
        @cache_timeout ||= 5.minutes
      end

      def cache_timeout=(val)
        @cache_timeout = val
      end
    end

    private

    def non_cacheable_response
      @listener.set_expiry nil, private: true, "no-cache" => true
      @listener.set_etag('')
    end

    def cacheable_response
      timeout = self.class.cache_timeout
      if @page.respond_to?(:cache_timeout)
        timeout = @page.cache_timeout
      end

      @listener.set_expiry timeout, public: true, private: false
    end

    def cacheable?
      @listener.cacheable_request? && @page.cache?
    end

  end
end
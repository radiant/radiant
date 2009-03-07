
class ResponseCache
  include ActionController::Benchmarking::ClassMethods
  
  @@defaults = {
    :directory => ActionController::Base.page_cache_directory,
    :expire_time => 5.minutes,
    :default_extension => '.yml',
    :perform_caching => true,
    :logger => ActionController::Base.logger,
    :use_x_sendfile => false,
    :use_x_accel_redirect => false
  }
  cattr_accessor :defaults
  
  attr_accessor :directory, :expire_time, :default_extension, :perform_caching, :logger, :use_x_sendfile, :use_x_accel_redirect
  alias :page_cache_directory :directory
  alias :page_cache_extension :default_extension
  private :benchmark, :silence, :page_cache_directory,
    :page_cache_extension 
    
  # Creates a ResponseCache object with the specified options.
  #
  # Options are as follows:
  # :directory         :: the path to the temporary cache directory
  # :expire_time       :: the number of seconds a cached response is considered valid (defaults to 5 min)
  # :default_extension :: the extension cached files should use (defaults to '.yml')
  # :perform_caching   :: boolean value that turns caching on or off (defaults to true)
  # :logger            :: the application logging object (defaults to ActionController::Base.logger)
  # :use_x_sendfile    :: use X-Sendfile headers to speed up transfer of cached pages (not available on all web servers)
  # 
  def initialize(options = {})
    options = options.symbolize_keys.reverse_merge(defaults)
    self.directory            = options[:directory]
    self.expire_time          = options[:expire_time]
    self.default_extension    = options[:default_extension]
    self.perform_caching      = options[:perform_caching]
    self.logger               = options[:logger]
    self.use_x_sendfile       = options[:use_x_sendfile]
    self.use_x_accel_redirect = options[:use_x_accel_redirect]
  end
  
  # Caches a response object for path to disk.
  def cache_response(path, response)
    path = clean(path)
    write_response(path, response)
    response
  end
  
  # If perform_caching is set to true, updates a response object so that it mirrors the
  # cached version. The request object is required to perform Last-Modified/If-Modified-Since
  # checks--it is left optional to allow for backwards compatability.
  def update_response(path, response, request=nil)
    if perform_caching
      path = clean(path)
      read_response(path, response, request)
    end
    response
  end
  
  # Returns metadata for path.
  def read_metadata(path)
    path = clean(path)
    name = "#{page_cache_path(path)}.yml"
    if File.exists?(name) and not File.directory?(name)
      content = File.open(name, "rb") { |f| f.read }
      metadata = YAML::load(content)
      metadata if metadata['expires'] >= Time.now
    end
  rescue
    nil
  end
  
  # Returns true if a response is cached at the specified path.
  def response_cached?(path)
    perform_caching && !!read_metadata(path)
  end
    
  # Expires the cached response for the specified path.
  def expire_response(path)
    path = clean(path)
    expire_page(path)
  end
  
  # Expires the entire cache.
  def clear
    Dir["#{directory}/*"].each do |f|
      FileUtils.rm_rf f
    end
  end
  
  # Returns the singleton instance for an application.
  def self.instance
    @@instance ||= new
  end
  
  private
    # Ensures that path begins with a slash and remove extra slashes.
    def clean(path)
      path = path.gsub(%r{/+}, '/')
      %r{^/?(.*?)/?$}.match(path)
      "/#{$1}"
    end

    # Reads a cached response from disk and updates a response object.
    def read_response(path, response, request)
      file_path = page_cache_path(path)
      if metadata = read_metadata(path)
        response.headers.merge!(metadata['headers'] || {})
        if client_has_cache?(metadata, request)
          response.headers.merge!('Status' => '304 Not Modified')
        elsif use_x_accel_redirect
          response.headers.merge!('X-Accel-Redirect' => "#{file_path}.data")
        elsif use_x_sendfile
          response.headers.merge!('X-Sendfile' => "#{file_path}.data")
        else
          response.body = File.open("#{file_path}.data", "rb") {|f| f.read}
        end
      end
      response
    end

    def client_has_cache?(metadata, request)
      return false unless request
      request_time = Time.httpdate(request.env["HTTP_IF_MODIFIED_SINCE"]) rescue nil
      response_time = Time.httpdate(metadata['headers']['Last-Modified']) rescue nil
      request_etag = request.env["HTTP_IF_NONE_MATCH"] rescue nil
      response_etag = metadata['headers']['ETag'] rescue nil
      (request_time && response_time && response_time <= request_time) || (request_etag && response_etag && request_etag == response_etag)
    end
    
    # Writes a response to disk.
    def write_response(path, response)
      if response.cache_timeout
        if Time === response.cache_timeout
          expires = response.cache_timeout
        else
          expires = Time.now + response.cache_timeout
        end
      else
        expires = Time.now + self.expire_time
      end
      response.headers['Last-Modified'] ||= Time.now.httpdate
      response.headers['ETag'] ||= Digest::SHA1.hexdigest(response.body)
      metadata = {
        'headers' => response.headers,
        'expires' => expires
      }.to_yaml
      cache_page(metadata, response.body, path)
    end

    def page_cache_path(path)
      path = (path.empty? || path == "/") ? "/_site-root" : URI.unescape(path)
      root_dir = File.expand_path(page_cache_directory)
      cache_path = File.expand_path(File.join(root_dir, path), root_dir)
      cache_path if cache_path.index(root_dir) == 0
    end

    def expire_page(path)
      return unless perform_caching

      if path = page_cache_path(path)
        benchmark "Expired page: #{path}" do
          File.delete("#{path}.yml") if File.exists?("#{path}.yml")
          File.delete("#{path}.data") if File.exists?("#{path}.data")
        end
      end
    end

    def cache_page(metadata, content, path)
      return unless perform_caching

      if path = page_cache_path(path)
        benchmark "Cached page: #{path}" do
          FileUtils.makedirs(File.dirname(path))
          #dont want yml without data
          File.open("#{path}.data", "wb+") { |f| f.write(content) }
          File.open("#{path}.yml", "wb+") { |f| f.write(metadata) }
        end
      end
    end
end

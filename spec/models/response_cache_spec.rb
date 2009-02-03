require File.dirname(__FILE__) + '/../spec_helper'

describe ResponseCache do
  class SilentLogger
    def method_missing(*args); end
  end
  
  class TestResponse < ActionController::TestResponse
    def initialize(body = '', headers = {})
      self.body = body
      self.headers = headers
    end
  end
  
  before :all do
    @dir = File.expand_path("#{RAILS_ROOT}/test/cache")
    @baddir = File.expand_path("#{RAILS_ROOT}/test/badcache")
    @old_perform_caching = ResponseCache.defaults[:perform_caching]
    ResponseCache.defaults[:perform_caching] = true
  end
  
  before :each do
    FileUtils.rm_rf @baddir
    @cache = ResponseCache.new(
      :directory => @dir,
      :perform_caching => true
    )
    @cache.clear
  end
  
  after :each do
    FileUtils.rm_rf @dir if File.exists? @dir
  end
  
  after :all do
    ResponseCache.defaults[:perform_caching] = @old_preform_caching
  end
  
  it 'should initialize with defaults' do
    @cache = ResponseCache.new
    @cache.directory.should == "#{RAILS_ROOT}/cache"
    @cache.expire_time.should == 5.minutes
    @cache.default_extension.should == '.yml'
    @cache.logger.should be_kind_of(ActiveSupport::BufferedLogger)
  end
  
  it 'should initialize with options' do
    @cache = ResponseCache.new(
      :directory         => "test",
      :expire_time       => 5,
      :default_extension => ".xhtml",
      :perform_caching   => false,
      :logger            => SilentLogger.new
    )
    @cache.directory.should == "test"
    @cache.expire_time.should == 5
    @cache.default_extension.should == ".xhtml"
    @cache.perform_caching.should == false
    @cache.logger.should be_kind_of(SilentLogger)
  end
  
  it 'should cache response' do
    ['test/me', '/test/me', 'test/me/', '/test/me/', 'test//me'].each do |url|
      @cache.clear
      response = response('content', 'Last-Modified' => 'Tue, 27 Feb 2007 06:13:43 GMT')
      response.cache_timeout = Time.gm(2007, 2, 8, 17, 37, 9)
      @cache.cache_response(url, response)
      name = "#{@dir}/test/me.yml"
      File.exists?(name).should == true
      file(name).should == "--- \nexpires: 2007-02-08 17:37:09 Z\nheaders: \n  Last-Modified: Tue, 27 Feb 2007 06:13:43 GMT\n" 
      data_name = "#{@dir}/test/me.data"
      file(data_name).should == "content" 
    end
  end
  
  it 'cache response with extension' do
    @cache.cache_response("styles.css", response('content'))
    File.exists?("#{@dir}/styles.css.yml").should == true
  end
  
  it 'cache response without caching' do
    @cache.perform_caching = false
    @cache.cache_response('test', response('content'))
    File.exists?("#{@dir}/test.yml").should == false
  end
  
  it 'update response' do
    @cache.cache_response('/test/me', response('content'))
    ['test/me', '/test/me', 'test/me/', '/test/me/', 'test//me'].each do |url|
      @cache.update_response(url, response, ActionController::TestRequest).body.should == 'content'
    end
  end

  it 'update response nonexistant' do
    @cache.update_response('nothing/here', response, ActionController::TestRequest).body.should == ''
  end
  
  it 'update response without caching' do
    @cache.cache_response('/test/me', response('content'))
    @cache.perform_caching = false
     @cache.update_response('/test/me', response, ActionController::TestRequest).body.should == ''
  end
  
  it 'cache' do
    result = @cache.cache_response('test', response('content', 'Content-Type' => 'text/plain'))
    cached = @cache.update_response('test', response, ActionController::TestRequest)
    cached.body.should == 'content'
    cached.headers['Content-Type'].should == 'text/plain'
    result.should be_kind_of(TestResponse)
  end
  
  it 'expire response' do
    @cache.cache_response('test', response('content'))
    @cache.expire_response('test')
    @cache.update_response('test', response, ActionController::TestRequest).body.should == ''
  end
  
  it 'clear' do
    @cache.cache_response('test1', response('content'))
    @cache.cache_response('test2', response('content'))
    Dir["#{@dir}/*"].size.should == 4
    
    @cache.clear
    Dir["#{@dir}/*"].size.should == 0
  end
  
  it 'response_cached?' do
    @cache.response_cached?('test').should == false
    result = @cache.cache_response('test', response('content'))
    @cache.response_cached?('test').should == true
  end
  
  it 'response_cached? should not answer true when response is cached but preform_caching option is false' do
    @cache.cache_response('test', response('content'))
    @cache.perform_caching = false
    @cache.response_cached?('test').should == false
  end
  
  it 'response_cached? with timeout' do
    @cache.expire_time = 1
    result = @cache.cache_response('test', response('content'))
    sleep 1.5
    @cache.response_cached?('test').should == false
  end
  
  it 'response_cached? timeout with response setting' do
    @cache.expire_time = 1
    response = response('content')
    response.cache_timeout = 3.seconds
    result = @cache.cache_response('test', response)
    sleep 1.5
    @cache.response_cached?('test').should == true
    sleep 2
    @cache.response_cached?('test').should == false
  end
  
  it 'send using x_sendfile header' do
    @cache.use_x_sendfile = true
    result = @cache.cache_response('test', response('content', 'Content-Type' => 'text/plain'))
    cached = @cache.update_response('test', response, ActionController::TestRequest)
    cached.body.should == ''
    cached.headers['X-Sendfile'].should == "#{@dir}/test.data"
    cached.headers['Content-Type'].should == 'text/plain'
    result.should be_kind_of(TestResponse) 
  end

  it 'send using x_accel_redirect header' do
    @cache.use_x_accel_redirect = true
    result = @cache.cache_response('test', response('content', 'Content-Type' => 'text/plain'))
    cached = @cache.update_response('test', response, ActionController::TestRequest)
    cached.body.should == ''
    cached.headers['X-Accel-Redirect'].should == "#{@dir}/test.data"
    cached.headers['Content-Type'].should == 'text/plain'
    result.should be_kind_of(TestResponse) 
  end
  
  it 'send cached page with last modified' do
    last_modified = Time.now.httpdate
    result = @cache.cache_response('test', response('content', 'Last-Modified' => last_modified))
    request = ActionController::TestRequest.new
    request.env = { 'HTTP_IF_MODIFIED_SINCE' => last_modified }
    second_call = @cache.update_response('test', response, request)
    second_call.headers['Status'].should match(/^304/)
    second_call.body.should == ''
    result.should be_kind_of(TestResponse)
  end
  
  it "should send cached page with etag" do
    etag = Digest::SHA1.hexdigest('content')
    result = @cache.cache_response('test', response('content', 'ETag' => etag))
    request = ActionController::TestRequest.new
    request.env = { 'HTTP_IF_NONE_MATCH' => etag }
    second_call = @cache.update_response('test', response, request)
    second_call.headers['Status'].should match(/^304/)
    second_call.body.should == ''
    result.should be_kind_of(TestResponse)    
  end
  
  it 'send cached page with old last modified' do
    last_modified = Time.now.httpdate
    result = @cache.cache_response('test', response('content', 'Last-Modified' => last_modified))
    request = ActionController::TestRequest.new
    request.env = { 'HTTP_IF_MODIFIED_SINCE' => 5.minutes.ago.httpdate }
    second_call = @cache.update_response('test', response, request)
    second_call.body.should == 'content'
    result.should be_kind_of(TestResponse) 
  end
  
  it 'not cached if metadata empty' do
    FileUtils.makedirs(@dir)
    File.open("#{@dir}/test_me.yml", 'w') { }
    @cache.response_cached?('/test_me').should == false
  end

  it 'not cached if metadata broken' do
    FileUtils.makedirs(@dir)
    File.open("#{@dir}/test_me.yml", 'w') {|f| f.puts '::: bad yaml file:::' }
    @cache.response_cached?('/test_me').should == false
  end
  
  it 'not cached if metadata not hash' do
    FileUtils.makedirs(@dir)
    File.open("#{@dir}/test_me.yml", 'w') {|f| f.puts ':symbol' }
    @cache.response_cached?('/test_me').should == false
  end
  
  it 'not cached if metadata has no expire' do
    FileUtils.makedirs(@dir)
    File.open("#{@dir}/test_me.yml", 'w') { |f| f.puts "--- \nheaders: \n  Last-Modified: Tue, 27 Feb 2007 06:13:43 GMT\n" }
    @cache.response_cached?('/test_me').should == false
  end  
  
  it 'cache cant write outside dir' do
    @cache.cache_response('../badcache/cache_cant_write_outside_dir', response('content'))
    File.exist?("#{RAILS_ROOT}/test/badcache/cache_cant_write_outside_dir.yml").should == false
  end
  
  it 'cache cannot read outside dir' do
    FileUtils.makedirs(@baddir)
    @cache.cache_response('/test_me', response('content'))
    File.rename "#{@dir}/test_me.yml", "#{@baddir}/test_me.yml"
    File.rename "#{@dir}/test_me.data", "#{@baddir}/test_me.data"
    @cache.response_cached?('/../badcache/test_me').should == false
  end
  
  it 'cache cannot expire outside dir' do
    FileUtils.makedirs(@baddir)
    @cache.cache_response('/test_me', response('content'))
    File.rename "#{@dir}/test_me.yml", "#{@baddir}/test_me.yml"
    File.rename "#{@dir}/test_me.data", "#{@baddir}/test_me.data"
    @cache.expire_response('/../badcache/test_me')
    File.exist?("#{@baddir}/test_me.yml").should == true
    File.exist?("#{@baddir}/test_me.data").should == true
  end  

  it 'should store indexes correctly' do
    @cache.cache_response('/', response('content')) 
    @cache.response_cached?('_site-root').should == true
    @cache.response_cached?('/') .should == true
    File.exist?("#{@dir}/../cache.yml").should == false
    File.exist?("#{@dir}/../cache.data").should == false
  end 

  # Class Methods
  
  it 'should give access to a global instance' do
    ResponseCache.instance.should equal(ResponseCache.instance)
  end
  
  private
  
    def file(filename)
      open(filename) { |f| f.read } rescue ''
    end
    
    def response(*args)
      TestResponse.new(*args)
    end
  
end

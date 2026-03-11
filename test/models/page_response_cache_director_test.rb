require "test_helper"
require "ostruct"

class PageResponseCacheDirectorTest < ActiveSupport::TestCase
  setup do
    @listener = OpenStruct.new
    @listener.define_singleton_method(:set_etag) { |val| @etag = val }
    @listener.define_singleton_method(:set_expiry) { |time, opts| @expiry = [time, opts] }
    @listener.define_singleton_method(:cacheable_request?) { false }
    @page = OpenStruct.new
  end

  test "initializes with page and listener" do
    assert_nothing_raised { Radiant::PageResponseCacheDirector.new(@page, @listener) }
  end

  test "has default cache timeout of 5 minutes" do
    assert_equal 5.minutes, Radiant::PageResponseCacheDirector.cache_timeout
  end

  test "sets non-cacheable response when request not cacheable" do
    director = Radiant::PageResponseCacheDirector.new(@page, @listener)
    director.set_cache_control
    assert_equal '', @listener.instance_variable_get(:@etag)
    time, opts = @listener.instance_variable_get(:@expiry)
    assert_nil time
    assert_equal true, opts[:private]
  end

  test "sets cacheable response when request and page are cacheable" do
    @listener.define_singleton_method(:cacheable_request?) { true }
    @page.define_singleton_method(:cache?) { true }
    director = Radiant::PageResponseCacheDirector.new(@page, @listener)
    director.set_cache_control
    time, opts = @listener.instance_variable_get(:@expiry)
    assert_equal 5.minutes, time
    assert_equal true, opts[:public]
  end

  test "uses page cache_timeout when available" do
    @listener.define_singleton_method(:cacheable_request?) { true }
    @page.define_singleton_method(:cache?) { true }
    @page.define_singleton_method(:cache_timeout) { 14.days }
    director = Radiant::PageResponseCacheDirector.new(@page, @listener)
    director.set_cache_control
    time, _opts = @listener.instance_variable_get(:@expiry)
    assert_equal 14.days, time
  end
end

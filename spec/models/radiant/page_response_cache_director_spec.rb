require 'ostruct'

require File.dirname(__FILE__) + "/../../spec_helper"

describe Radiant::PageResponseCacheDirector do
  it 'initializes with a page and a listener' do
    lambda { described_class.new(Object.new, Object.new) }.should_not raise_error
  end

  it 'errors without a page and a listener' do
    lambda { described_class.new }.should raise_error
  end

  it 'has a default cache timeout' do
    described_class.cache_timeout.should == 5.minutes
  end

  it 'sets the cache timeout' do
    old_timeout = described_class.cache_timeout
    described_class.cache_timeout = 30.days
    described_class.cache_timeout.should == 30.days
    described_class.cache_timeout.should_not == old_timeout
  end

  let(:non_cacheable_params){ {:private => true, "no-cache" => true} }
  let(:cacheable_params){ {:public => true, :private => false} }
  let(:listener){ l = OpenStruct.new()
    l.stub!(:set_etag)
    l.stub!(:set_expiry)
    l
  }
  let(:page){ OpenStruct.new }

  it 'sets the non-cacheable response' do
    director = described_class.new(page, listener)
    listener.should_receive(:set_expiry).with(nil, non_cacheable_params)
    director.set_cache_control
  end

  it 'clears the etag' do
    director = described_class.new(page, listener)
    listener.should_receive(:set_etag).with('')
    director.set_cache_control
  end

  it 'sets the cacheable response to the default timeout' do
    listener.stub!(:cacheable_request?).and_return(true)
    page.stub!(:cache?).and_return(true)

    director = described_class.new(page, listener)

    listener.should_receive(:set_expiry).with(described_class.cache_timeout, cacheable_params)
    director.set_cache_control
  end

  it 'sets the cacheable response to the page timeout' do
    listener.stub!(:cacheable_request?).and_return(true)
    page.stub!(:cache?).and_return(true)
    page.stub!(:cache_timeout).and_return(14.days)

    director = described_class.new(page, listener)

    listener.should_receive(:set_expiry).with(14.days, cacheable_params)
    director.set_cache_control
  end

  it 'is not cacheable if the listener request is not cacheable' do
    listener.stub!(:cacheable_request?).and_return(false)
    director = described_class.new(page, listener)

    listener.should_receive(:set_expiry).with(nil, non_cacheable_params)
    director.set_cache_control
  end

  it 'is not cacheable if the page is not cacheable' do
    listener.stub!(:cacheable_request?).and_return(true)
    page.stub!(:cache?).and_return(false)
    director = described_class.new(page, listener)

    listener.should_receive(:set_expiry).with(nil, non_cacheable_params)
    director.set_cache_control
  end
end
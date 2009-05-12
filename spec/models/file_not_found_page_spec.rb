require File.dirname(__FILE__) + '/../spec_helper'

describe FileNotFoundPage do
  dataset :file_not_found
  test_helper :render
  
  before(:each) do
    @page = pages(:file_not_found)
  end
  
  it 'should have a working url tag' do
    assert_renders '/gallery/asdf?param=4', '<r:attempted_url />', '/gallery/asdf?param=4'
  end

  it 'should correctly quote the url' do
    assert_renders '/gallery/&lt;script&gt;alert(&quot;evil&quot;)&lt;/script&gt;', '<r:attempted_url />', '/gallery/<script>alert("evil")</script>'
  end
  
  it 'should be a virtual page' do
    @page.should be_virtual
  end
  
  it 'should not be cached' do
    @page.should_not be_cache
  end
  
  it 'should return a 404 status code' do
    @page.response_code.should == 404
  end
  
end

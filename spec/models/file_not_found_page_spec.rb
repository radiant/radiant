require File.dirname(__FILE__) + '/../spec_helper'

describe FileNotFoundPage do
  dataset :file_not_found
  test_helper :render
  
  let(:file_not_found){ pages(:file_not_found) }
  
  its(:allowed_children){ should == [] }
  
  describe '<r:attempted_url>' do
    it 'should have a working url tag' do
      @page = file_not_found
      assert_renders '/gallery/asdf?param=4', '<r:attempted_url />', '/gallery/asdf?param=4'
    end

    it 'should correctly quote the url' do
      @page = file_not_found
      assert_renders '/gallery/&lt;script&gt;alert(&quot;evil&quot;)&lt;/script&gt;', '<r:attempted_url />', '/gallery/<script>alert("evil")</script>'
    end
  end
  
  it 'should be a virtual page' do
    file_not_found.should be_virtual
  end
  
  it 'should not be cached' do
    file_not_found.should_not be_cache
  end
  
  it 'should return a 404 status code' do
    file_not_found.response_code.should == 404
  end
  
end

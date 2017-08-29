require File.dirname(__FILE__) + '/../spec_helper'
require 'rspec/its'

describe FileNotFoundPage do
  #dataset :file_not_found
  test_helper :render

  let(:file_not_found){ FactoryGirl.create(:file_not_found_page) }

  describe '#allowed_children' do
    subject { super().allowed_children }
    it { is_expected.to eq([]) }
  end

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
    expect(file_not_found).to be_virtual
  end

  it 'should not be cached' do
    expect(file_not_found).not_to be_cache
  end

  it 'should return a 404 status code' do
    expect(file_not_found.response_code).to eq(404)
  end

end

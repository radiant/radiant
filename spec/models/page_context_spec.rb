require File.dirname(__FILE__) + '/../spec_helper'

describe PageContext do
  before :each do
    @page = FactoryGirl.build(:home)
    @context = PageContext.new(@page)
    @parser = Radius::Parser.new(@context, tag_prefix: 'r')
    @context = @parser.context
  end

  it 'should raise an error when it encounters a missing tag' do
    expect { @parser.parse('<r:missing />') }.to raise_error(StandardTags::TagError)
  end

  it 'should initialize correctly' do
    expect(@page).to equal(@context.page)
  end

  it 'should give tags access to the request' do
    @page.save!
    another = FactoryGirl.create(:published_page, parent_id: @page.id, title: 'Another')
    @context.define_tag("if_request") { |tag| tag.expand if tag.locals.page.request }
    expect(parse('<r:if_request>tada!</r:if_request>')).to match(/^$/)

    @page.request = ActionDispatch::TestRequest.new
    expect(parse('<r:if_request>tada!</r:if_request>')).to include("tada!")    
    expect(parse('<r:find path="/another/"><r:if_request>tada!</r:if_request></r:find>')).to include("tada!")
  end

  it 'should give tags access to the response' do
    @page.save!
    another = FactoryGirl.create(:published_page, parent_id: @page.id, title: 'Another')
    @context.define_tag("if_response") { |tag| tag.expand if tag.locals.page.response }
    expect(parse('<r:if_response>tada!</r:if_response>')).to match(/^$/)

    @page.response = ActionDispatch::TestRequest.new
    expect(parse('<r:if_response>tada!</r:if_response>')).to include("tada!")
    expect(parse('<r:find path="/another/"><r:if_response>tada!</r:if_response></r:find>')).to include("tada!")
  end

  private

    def parse(input)
      @parser.parse(input)
    end

end

describe PageContext, "when errors are not being raised" do
  before :each do
    @page = FactoryGirl.build(:home)
    @context = PageContext.new(@page)
    @parser = Radius::Parser.new(@context, tag_prefix: 'r')
    allow(@parser.context).to receive(:raise_errors?).and_return(false)
    @context = @parser.context
  end

  it 'should output an error when it encounters a missing tag' do
    expect(@parser.parse('<r:missing />')).to include("undefined tag `missing'")
  end

  it 'should pop the stack when an error occurs' do

    expect(@context.current_nesting).to be_empty
    @parser.context.define_tag("error") { |tag| raise "Broken!" }
    expect(@parser.parse("<r:error/>")).to match(/Broken\!/)
    expect(@context.current_nesting).to be_empty
  end
end

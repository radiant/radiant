require File.dirname(__FILE__) + '/../spec_helper'

describe PageContext do
  dataset :pages
  
  before :each do
    @page = pages(:radius)
    @context = PageContext.new(@page)
    @parser = Radius::Parser.new(@context, :tag_prefix => 'r')
  end
  
  it 'should raise an error when it encounters a missing tag' do
    lambda { @parser.parse('<r:missing />') }.should raise_error(StandardTags::TagError)
  end
  
  it 'should initialize correctly' do
    @page.should equal(@context.page)
  end
  
  it 'should give tags access to the request' do
    @context.define_tag("if_request") { |tag| tag.expand if tag.locals.page.request }
    parse('<r:if_request>tada!</r:if_request>').should match(/^$/)
    
    @page.request = ActionController::TestRequest.new
    parse('<r:if_request>tada!</r:if_request>').should include("tada!") 
    parse('<r:find url="/another/"><r:if_request>tada!</r:if_request></r:find>').should include("tada!") 
  end
  
  it 'should give tags access to the response' do
    @context.define_tag("if_response") { |tag| tag.expand if tag.locals.page.response }
    parse('<r:if_response>tada!</r:if_response>').should match(/^$/) 
    
    @page.response = ActionController::TestResponse.new
    parse('<r:if_response>tada!</r:if_response>').should include("tada!")
    parse('<r:find url="/another/"><r:if_response>tada!</r:if_response></r:find>').should include("tada!")
  end
  
  private
    
    def parse(input)
      @parser.parse(input)
    end
  
end

describe PageContext, "when errors are not being raised" do
  dataset :pages
  
  before :each do
    @page = pages(:radius)
    @context = PageContext.new(@page)
    @context.stub!(:raise_errors?).and_return(false)
    @parser = Radius::Parser.new(@context, :tag_prefix => 'r')
  end
  
  it 'should output an error when it encounters a missing tag' do
    @parser.parse('<r:missing />').should include("undefined tag `missing'")
  end
  
  it 'should pop the stack when an error occurs' do
    @context.current_nesting.should be_empty
    @context.define_tag("error") { |tag| raise "Broken!" }
    @parser.parse("<r:error/>").should match(/Broken\!/)
    @context.current_nesting.should be_empty
  end
end
